# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # parses problem page and collect problem information
    module PageParser
      module_function

      SECTION_TYPES = [
        {
          key: 'constraints',
          patterns: [
            '^制約$',
            '^Constraints$'
          ]
        },
        {
          key: 'input format',
          patterns: [
            '^入出?力(形式)?$',
            '^Inputs?\s*(,|and)?\s*(Outputs?)?\s*(Format)?$'
          ]
        },
        {
          key: 'sample input %<no>s',
          patterns: [
            '^入力例\s*(?<no>\d+)?$',
            '^入力\s*(?<no>\d+)$',
            '^Sample\s*Input\s*(?<no>\d+)?$',
            '^Input\s*Example\s*(?<no>\d+)?$',
            '^Input\s*(?<no>\d+)$'
          ]
        },
        {
          key: 'sample output %<no>s',
          patterns: [
            '^出力例\s*(?<no>\d+)?$',
            '^出力\s*(?<no>\d+)$',
            '^入力例\s*(?<no>\d+)?\s*に対する出力例$',
            '^Sample\s*Output\s*(?<no>\d+)?$',
            '^Output\s*Example\s*(?<no>\d+)?$',
            '^Output\s*(?<no>\d+)$',
            '^Output\s*for\s*(the)?\s*Sample\s*Input\s*(?<no>\d+)?$'
          ]
        }
      ].freeze

      def process(pbm)
        sections = collect_sections(pbm.page)
        apply_sections(pbm, sections)
      end

      def collect_sections(page)
        sections = {}
        %w[h2 h3].each do |tag|
          page
            .search(tag)
            .each do |h|
              key = find_key(h)
              key && sections[key] ||= parse_section(h)
            end
        end
        sections
      end

      def find_key(h)
        title = normalize(h.content)
        SECTION_TYPES.each do |grp|
          grp[:patterns].each do |pat|
            m = title.match(/#{pat}/i)
            next unless m

            no = m.names.include?('no') && m['no'] || '1'
            return format(grp[:key], no: no)
          end
        end
        nil
      end

      def parse_section(h)
        text = ''
        pre = nil
        nx = h.next
        while nx && nx.name != h.name
          text += nx.content.gsub("\r\n", "\n")
          %w[pre blockquote].each do |tag|
            pre ||= (nx.name == tag ? nx : nx.search(tag)[0])
          end
          nx = nx.next
        end
        code = (pre&.text || '').lstrip.gsub("\r\n", "\n")
        [text, code]
      end

      def apply_sections(pbm, sections)
        sections.each do |key, (text, code)|
          case key
          when 'constraints'
            pbm.desc += text
          when 'input format'
            pbm.desc += text
            pbm.fmt = code
          when /^sample input (?<no>\d+)$/
            pbm.add_smp($LAST_MATCH_INFO[:no], :in, code)
          when /^sample output (?<no>\d+)$/
            pbm.add_smp($LAST_MATCH_INFO[:no], :exp, code)
          end
        end
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
