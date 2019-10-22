# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # parses problem page and extract modulo values
    module Modulo
      module_function

      SECTIONS = [
        Problem::SECTION_OUT_FMT,
        Problem::SECTION_STATEMENT
      ]
      VALUE_PATTERNS = [
        '<var>([^<>]+)<\/var>',
        '\\\\\(([^()]+)\\\\\)', # \(998244353\)
        '\$([^$]+)\$',
        '([\d,]+)'
      ].freeze
      PATTERNS =
        VALUE_PATTERNS
        .map do |pat|
          [
            pat + '\s*(?:\([^()]+\)\s*)?で割った(?:剰余|余り|あまり)',
            '(?:modulo|mod|divided\s*by|dividing\s*by)\s*' + pat
          ]
        end
        .flatten

      def process(pbm)
        mods = []
        SECTIONS.any? do |section|
          html = section_html(pbm, section)
          mods = parse(html)
          !mods.empty?
        end
        pbm.constants += mods
      end

      def section_html(pbm, section)
        pbm.sections[section]&.html || ''
      end

      def parse(str)
        str = normalize_content(str)
        PATTERNS
          .flat_map do |pat|
            str
              .scan(/#{pat}/i)
              .map { |m| normalize_value(m[0]) }
              .reject(&:empty?)
              .map { |v| Problem::Constant.new(nil, :mod, v) }
          end
      end

      def normalize_content(s)
        s
          .tr('　０-９Ａ-Ｚａ-ｚ', ' 0-9A-Za-z')
          .gsub(%r{[^一-龠_ぁ-ん_ァ-ヶーa-zA-Z0-9 -/:-@\[-`\{-~]}, '')
          .gsub(/{\\rm\s*mod\s*}/i, 'mod') # {\rm mod} -> mod
          .gsub(/\\rm\s*{\s*mod\s*}\\?/i, 'mod') # \rm{mod}\ -> mod
          .gsub(/\\mbox\s*{\s*mod\s*}/i, 'mod') # \mbox{mod} -> mod
          .gsub(%r{<var>\s*mod\s*</var>}i, 'mod') # <var>mod</var> -> mod
          .strip
      end

      def normalize_value(s)
        s
          .gsub(/^(.+)\(.+\)$/, '\1') # 1000000007 (10^9+7)
          .gsub(/^(.+)=.+$/, '\1') # 1000000007 =10^9+7
          .gsub(/[{}()\\, ]/, '')
      end
    end
  end
end
