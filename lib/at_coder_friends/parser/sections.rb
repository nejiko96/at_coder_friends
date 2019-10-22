# frozen_string_literal: true

module AtCoderFriends
  module Parser
    module SectionsConstants
      SECTION_DEFS = [
        {
          key: Problem::SECTION_STATEMENT,
          patterns: [
            '^問題文?$',
            '^Problem\s*(Statement|Setting)?$',
            '^Statement$'
          ]
        },
        {
          key: Problem::SECTION_CONSTRAINTS,
          patterns: [
            '^制約$',
            '^入力制限$',
            '^Constraints$'
          ]
        },
        {
          key: Problem::SECTION_IN_FMT,
          patterns: [
            '^入力(形式)?$',
            '^Inputs?\s*(Format)?$'
          ]
        },
        {
          key: Problem::SECTION_OUT_FMT,
          patterns: [
            '^出力(形式)?$',
            '^Outputs?\s*(Format)?$'
          ]
        },
        {
          key: Problem::SECTION_IO_FMT,
          patterns: [
            '^入出力(形式)?$',
            '^Input\s*(and)?\s*Output\s*(Format)?$'
          ]
        },
        {
          key: Problem::SECTION_IN_SMP,
          patterns: [
            '^入力例\s*(?<no>\d+)?$',
            '^入力\s*(?<no>\d+)$',
            '^Sample\s*Input\s*(?<no>\d+)?$',
            '^Input\s*Example\s*(?<no>\d+)?$',
            '^Input\s*(?<no>\d+)$'
          ]
        },
        {
          key: Problem::SECTION_OUT_SMP,
          patterns: [
            '^出力例\s*(?<no>\d+)?$',
            '^出力\s*(?<no>\d+)$',
            '^入力例\s*(?<no>\d+)?\s*に対する出力例$',
            '^Sample\s*Output\s*(?<no>\d+)?$',
            '^Output\s*Example\s*(?<no>\d+)?$',
            '^Output\s*(?<no>\d+)$',
            '^Output\s*for\s*(the)?\s*Sample\s*Input\s*(?<no>\d+)?$'
          ]
        },
        {
          key: Problem::SECTION_IO_SMP,
          patterns: [
            '^入出力の?例\s*(\d+)?$',
            '^サンプル\s*(\d+)?$',
            '^Sample\s*Input\s*(and)?\s*Output\s*(\d+)?$',
            '^Samples?\s*(\d+)?$'
          ]
        }
      ].freeze
    end

    # parses problem page and builds section table
    module Sections
      include SectionsConstants

      module_function

      def process(pbm)
        sections = collect_sections(pbm.page)
        pbm.sections = sections
      end

      def collect_sections(page)
        %w[h2 h3].each_with_object({}) do |tag, sections|
          page
            .search(tag)
            .each do |h|
              key = find_key(h)
              key && sections[key] ||= SectionWrapper.new(h)
            end
        end
      end

      def find_key(h)
        title = normalize(h.content)
        key = nil
        SECTION_DEFS.any? do |grp|
          grp[:patterns].any? do |pat|
            if (m = title.match(/#{pat}/i))
              no = m.names.include?('no') && m['no'] || '1'
              key = format(grp[:key], no: no)
            end
          end
        end
        key
      end

      def normalize(s)
        s
          .tr('　０-９Ａ-Ｚａ-ｚ', ' 0-9A-Za-z')
          .gsub(/[^一-龠_ぁ-ん_ァ-ヶーa-zA-Z0-9 ]/, '')
          .strip
      end
    end
  end
end
