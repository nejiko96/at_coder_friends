# frozen_string_literal: true

require 'English'

module AtCoderFriends
  module Scraping
    # fetch problems from tasks page
    module Tasks
      ARC001_SECTION_XPATH = '//h3[.="%<title>s"]/following-sibling::section'
      TITLE_PATTERNS = [
        {
          re: '^(制約|Constraints)$',
          key: 'constraints'
        },
        {
          re: '^(入出?力|Inputs?\s*((,|and)?\s*Outputs?)?\s*(Format)?)$',
          key: 'input format'
        },
        {
          re: '^(入力例|Sample\s*Input|Input\s*Example)\s*(?<no>\d+)?$',
          key: 'sample input %<no>s'
        },
        {
          re: '^(出力例|Sample\s*Output|Output\s*Example)\s*(?<no>\d+)?$',
          key: 'sample output %<no>s'
        },
        {
          re: '^(Output\s*for\s*(the)\s*Sample\s*Input)\s*(?<no>\d+)?$',
          key: 'sample output %<no>s'
        }
      ].freeze

      def fetch_all
        puts "***** fetch_all #{contest} *****"
        fetch_assignments.map do |q, url|
          pbm = fetch_problem(q, url)
          yield pbm if block_given?
          pbm
        end
      end

      def fetch_assignments
        url = contest_url('tasks')
        puts "fetch list from #{url} ..."
        page = fetch_with_auth(url)
        page
          .search('//table[1]//td[1]//a')
          .each_with_object({}) do |a, h|
            h[a.text] = a[:href]
          end
      end

      def fetch_problem(q, url)
        puts "fetch problem from #{url} ..."
        page = fetch_with_auth(url)
        Problem.new(q) do |pbm|
          pbm.html = page.body
          @matched_section = {}
          list_section(page)
            .map { |h3, section| conv_section(h3, section) }
            .each { |args| match_section(pbm, *args) }
        end
      end

      def list_section(page)
        if contest == 'arc001'
          list_section_arc001(page)
        else
          list_section_other(page)
        end
      end

      def list_section_arc001(page)
        page
          .search('//h3').map do |h3|
            query = format(ARC001_SECTION_XPATH, title: h3.content)
            section = page.search(query)[0]
            next unless section

            [h3, section]
          end
          .compact
      end

      def list_section_other(page)
        page.search('//*[./h3]').map do |section|
          h3 = section.search('h3')[0]
          [h3, section]
        end
      end

      def conv_section(h3, section)
        title = normalize(h3.content)
        text = section.content
        code = section.search('pre')[0]&.content || ''
        code = code.lstrip.gsub("\r\n", "\n")
        [title, text, code]
      end

      def match_section(pbm, title, text, code)
        pat = TITLE_PATTERNS.find { |h| title =~ /#{h[:re]}/i }
        return unless pat

        m = title.match(/#{pat[:re]}/i)
        no = m.names.include?('no') ? m['no'] : '1'
        key = format(pat[:key], no: no)
        return if @matched_section[key]

        case key
        when 'constraints'
          pbm.desc += text
        when 'input format'
          pbm.desc += text
          pbm.fmt = code
        when /^sample input \d+$/
          pbm.add_smp(no, :in, code)
        when /^sample output \d+$/
          pbm.add_smp(no, :exp, code)
        end

        @matched_section[key] = true
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
