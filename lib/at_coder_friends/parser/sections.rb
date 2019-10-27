# frozen_string_literal: true

module AtCoderFriends
  module Parser
    module SectionsConstants
      SECTION_DEFS = [
        {
          key: Problem::SECTION_STATEMENT,
          pattern: /
            \A(
              問題文?
              |Problem\s*(Statement|Setting)?
              |Statement
              |Description
            )\z
          /xi
        },
        {
          key: Problem::SECTION_TASK,
          pattern: /
            \A(
              課題
              |Task
            )\z
          /xi
        },
        {
          key: Problem::SECTION_CONSTRAINTS,
          pattern: /
            \A(
              (入力(の|に関する)?)?(制約|制限)
              |Constraints
            )\z
          /xi
        },
        {
          key: Problem::SECTION_IN_FMT,
          pattern: /
            \A(
              入力(形式)?
              |Inputs?\s*(Format)?
            )\z
          /xi
        },
        {
          key: Problem::SECTION_OUT_FMT,
          pattern: /
            \A(
              出力(形式)?
              |Outputs?\s*(Format)?
            )\z
          /xi
        },
        {
          key: Problem::SECTION_IO_FMT,
          pattern: /
            \A(
              入出力(形式)?
              |Input\s*(and)?\s*Output\s*(Format)?
            )\z
          /xi
        },
        {
          key: Problem::SECTION_IN_SMP,
          pattern: /
            \A(
              入力例\s*(?<no>\d+)?
              |入力\s*(?<no>\d+)
              |Sample\s*Input\s*(?<no>\d+)?
              |Input\s*Example\s*(?<no>\d+)?
              |Input\s*(?<no>\d+)
            )\z
          /xi
        },
        {
          key: Problem::SECTION_OUT_SMP,
          pattern: /
            \A(
              出力例\s*(?<no>\d+)?
              |出力\s*(?<no>\d+)
              |入力例\s*(?<no>\d+)?\s*に対する出力例
              |Sample\s*Output\s*(?<no>\d+)?
              |Output\s*Example\s*(?<no>\d+)?
              |Output\s*(?<no>\d+)
              |Output\s*for\s*(the)?\s*Sample\s*Input\s*(?<no>\d+)?
            )\z
          /xi
        },
        {
          key: Problem::SECTION_IO_SMP,
          pattern: /
            \A(
              入出力の?例\s*(\d+)?
              |サンプル\s*(\d+)?
              |Sample\s*Input\s*(and)?\s*Output\s*(\d+)?
              |Samples?\s*(\d+)?
            )\z
          /xi
        }
      ].freeze
    end

    # parses problem page and builds section table
    module Sections
      include SectionsConstants

      module_function

      def process(pbm)
        sections = collect_sections(pbm.page)
        div = pbm.page.search('div#task-statement')[0]
        div && sections[Problem::SECTION_INTRO] = IntroductionWrapper.new(div)
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
          if (m = title.match(grp[:pattern]))
            no = m.names.include?('no') && m['no'] || '1'
            key = format(grp[:key], no: no)
          end
        end
        key
      end

      def normalize(s)
        s
          .tr('０-９Ａ-Ｚａ-ｚ', '0-9A-Za-z')
          .gsub(/[[:space:]]/, ' ') # &npsp; full-width space
          .gsub(/[^一-龠_ぁ-ん_ァ-ヶーa-zA-Z0-9 ]/, '')
          .strip
      end
    end
  end
end
