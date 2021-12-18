# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # parses problem page and extract modulo values
    module Modulo
      module_function

      SECTIONS = [
        Problem::SECTION_OUT_FMT,
        Problem::SECTION_STATEMENT,
        Problem::SECTION_TASK,
        Problem::SECTION_INTRO
      ].freeze
      # \(998244353\)
      # 十億九
      VALUE_PATTERN = %r{
        (?:
          <var>([^<>]+)</var>
          |\\\(([^()]+)\\\)
          |\$([^$]+)\$
          |\{([^{}]+)\}
          |([\d,^+]+)
          |([一二三四五六七八九十百千万億]+)
        )
      }x.freeze
      # <var>1,000,000,007</var> (素数)で割った余り
      MOD_PATTERN = /
        (?:
          #{VALUE_PATTERN}\s*(?:\([^()]+\)\s*)?で割った(?:剰余|余り|あまり)
          |(?:modulo|mod|divided\s*by|dividing\s*by)\s*#{VALUE_PATTERN}
        )
      /xi.freeze

      def process(pbm)
        mods = []
        SECTIONS.any? do |section|
          next unless (html = pbm.sections[section]&.html)

          !(mods = parse(html)).empty?
        end
        pbm.constants += mods
      end

      def parse(str)
        str = normalize_content(str)
        str
          .scan(MOD_PATTERN)
          .map(&:compact)
          .map { |(v)| normalize_value(v) }
          .reject(&:empty?)
          .uniq
          .map { |v| Problem::Constant.new('mod', :mod, v) }
      end

      def normalize_content(s)
        s
          .tr('０-９Ａ-Ｚａ-ｚ', '0-9A-Za-z')
          .gsub(/[[:space:]]/, ' ')
          .gsub(%r{[^一-龠_ぁ-んァ-ヶーa-zA-Z0-9 -/:-@\[-`\{-~]}, '')
          .gsub(/{\\rm\s*mod\s*}\\?/i, 'mod') # {\rm mod} -> mod
          .gsub(/\\rm\s*{\s*mod\s*}\\?/i, 'mod') # \rm{mod}\ -> mod
          .gsub(/\\mbox\s*{\s*mod\s*}/i, 'mod') # \mbox{mod} -> mod
          .gsub(%r{<var>\s*mod\s*</var>}i, 'mod') # <var>mod</var> -> mod
      end

      def normalize_value(s)
        s
          .gsub(/\A([^(=]+)[(=].*\z/, '\1') # 1000000007 (10^9+7), ... =10^9+7
          .gsub(/[{}()=\\ ]/, '')
      end
    end
  end
end
