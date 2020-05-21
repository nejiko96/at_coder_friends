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
      NAME_PAT = /[0-9a-z_{},]+/i.freeze
      NAMES_PAT = /#{NAME_PAT}(?:\s*,\s*#{NAME_PAT})*/.freeze
      NUM_PAT = /[-+*^0-9{}, ]+/.freeze
      MAX_PATTERN = /
        (?:
          (#{NAMES_PAT})\s*<\s*(#{NUM_PAT})
          |(#{NAMES_PAT})\s*は\s*#{NUM_PAT}\s*以上\s*(#{NUM_PAT})\s*以下の整数
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
          .select { |_, v| v && !v.empty? }
          .flat_map { |ks, v| ks.map { |k| [k, v] } }
          .uniq
          .map { |k, v| Problem::Constant.new(k, :max, v) }
      end

      def normalize_content(s)
        # 1) &npsp; , fill-width space -> half width space
        # 2) {i, j}->{i,j} {N-1}->{N} shortest match
        s
          .tr('０-９Ａ-Ｚａ-ｚ', '0-9A-Za-z')
          .gsub(/[[:space:]]/) { |c| c.gsub(/[^\t\n]/, ' ') } # 1)
          .gsub(%r{</?var>}i, "\t")
          .gsub(%r{<sup>([^<>]+)</sup>}i, '^\1')
          .gsub(%r{<sub>([^<>]+)</sub>}i, '_{\1}')
          .gsub(/<("[^"]*"|'[^']*'|[^'"<>])*>/, '')
          .gsub('&amp;', '&')
          .gsub(/(＜|≦|≤|&lt;|&leq?;|\\lt|\\leq?q?)/i, '<')
          .gsub('\\ ', ' ')
          .gsub('\\,', ',')
          .gsub('\\|', '|')
          .gsub('，', ', ')
          .gsub('×', '*')
          .gsub('\\lvert', '|')
          .gsub('\\rvert', '|')
          .gsub('\\mathit', '')
          .gsub('\\mathrm', '')
          .gsub('\\times', '*')
          .gsub(/\\begin(\{[^{}]*\})*/, '')
          .gsub(/\\end(\{[^{}]*\})*/, '')
          .gsub(/\{\}/, ' ')
          .gsub('|', '')
          .gsub(/\{.*?\}/) { |w| w.delete(' ()').gsub(/{(.+)-1}\z/, '\1') } # 2)
      end

      def normalize_names(s)
        # 1) {i,j}->{ij} shortest match
        s
          .gsub(/\{.*?\}/) { |w| w.delete(',') } # 1)
          .delete('{}')
          .gsub(/\s+/, '')
          .split(',')
          .reject(&:empty?)
      end

      def normalize_value(s)
        s
          .split(', ')
          &.map do |v|
            v
              .delete(' {}')
              .gsub(/\A[+*^,]+/, '') # remove preceding symbols
              .gsub(/[+*^,]+\z/, '') # remove trailing symbols
          end
          &.reject(&:empty?)
          &.first
      end
    end
  end
end
