# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # parses constraints
    module Constraints
      module_function

      SECTIONS = [
        Problem::SECTION_CONSTRAINTS,
        Problem::SECTION_IN_FMT,
        Problem::SECTION_IO_FMT,
        Problem::SECTION_STATEMENT
      ].freeze
      NAME_PAT = /[0-9a-z_{}, ]+/i.freeze
      NUM1_PAT = /[+*^0-9{},]+/.freeze
      NUM2_PAT = /[-+*^0-9{}, ]+/.freeze
      NUM3_PAT = /[+*^0-9{}, ]+/.freeze
      MAX_PATTERN = /
        (?:
          (#{NAME_PAT})\s*<\s*(#{NUM1_PAT})
          |(#{NAME_PAT})\s*は\s*#{NUM2_PAT}\s*以上\s*(#{NUM3_PAT})\s*以下の整数
        )
      /xmi.freeze

      def process(pbm)
        maxs = []
        SECTIONS.any? do |section|
          next unless (text = pbm.sections[section]&.html)

          !(maxs = parse(text)).empty?
        end
        pbm.constants += maxs
      end

      def parse(str)
        str = normalize_content(str)
        str
          .scan(MAX_PATTERN)
          .map(&:compact)
          .map { |k, v| [normalize_names(k), normalize_value(v)] }
          .reject { |_, v| v.empty? }
          .flat_map { |ks, v| ks.map { |k| [k, v] } }
          .uniq
          .map { |k, v| Problem::Constant.new(k, :max, v) }
      end

      def normalize_content(s)
        s
          .tr('０-９Ａ-Ｚａ-ｚ', '0-9A-Za-z')
          .gsub(/[[:space:]]/, ' ') # &npsp; fill-width space
          .gsub(%r{</?var>}i, "\t")
          .gsub(%r{<sup>([^<>]+)</sup>}i, '^\1')
          .gsub(%r{<sub>([^<>]+)</sub>}i, '_{\1}')
          .gsub('&amp;', '&')
          .gsub(/<("[^"]*"|'[^']*'|[^'"<>])*>/, ' ')
          .gsub(/(＜|≦|≤|&lt;|&leq?;|\\lt|\\leq?q?)(\{\})?/i, '<')
          .gsub('\\ ', ' ')
          .gsub('\\,', ',')
          .gsub('\\|', '|')
          .gsub('，', ', ')
          .gsub('×', '*')
          .gsub('\\lvert', '|')
          .gsub('\\rvert', '|')
          .gsub('\\mathit', '')
          .gsub('\\times', '*')
          .gsub('|', '')
          .gsub(/\s*([+*^]+)\s*/, '\1')
          .gsub(/\{.*?\}/) { |w| w.delete(' ()') } # {i, j}->{i,j} shortest
      end

      def normalize_names(s)
        s
          .gsub(/\{.*?\}/) { |w| w.delete(',') } # {i,j}->{ij} shortest match
          .delete(' {}')
          .split(',')
          .reject(&:empty?)
      end

      def normalize_value(s)
        s
          .delete(' {}')
          .gsub(/\A[+*^,]+/, '') # remove preceding symbols
          .gsub(/[+*^,]+\z/, '') # remove trailing symbols
      end
    end
  end
end
