# frozen_string_literal: true

require 'English'

module AtCoderFriends
  module Scraping
    # fetch problems from tasks page
    module Tasks
      XPATH_SECTION = '//h3[.="%<title>s"]/following-sibling::section'

      def constraints_pat
        config['constraints_pat'] || '^制約$'
      end

      def input_fmt_pat
        config['input_fmt_pat'] || '^入出?力$'
      end

      def input_smp_pat
        config['input_smp_pat'] || '^入力例\s*(?<no>[\d０-９]+)$'
      end

      def output_smp_pat
        config['output_smp_pat'] || '^出力例\s*(?<no>[\d０-９]+)$'
      end

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
          if contest == 'arc001'
            init_pbm_arc001(pbm, page)
          else
            init_pbm(pbm, page)
          end
        end
      end

      def init_pbm(pbm, page)
        page.search('//*[./h3]').each do |section|
          h3 = section.search('h3')[0]
          parse_section(pbm, h3, section)
        end
      end

      def init_pbm_arc001(pbm, page)
        page.search('//h3').each do |h3|
          query = format(XPATH_SECTION, title: h3.content)
          sections = page.search(query)
          sections[0] && parse_section(pbm, h3, sections[0])
        end
      end

      def parse_section(pbm, h3, section)
        title = h3.content.strip
        title.delete!("\u008f\u0090") # agc002
        text = section.content
        code = section.search('pre')[0]&.content || ''
        case title
        when /#{constraints_pat}/
          pbm.desc += text
        when /#{input_fmt_pat}/
          pbm.desc += text
          pbm.fmt = code
        when /#{input_smp_pat}/
          pbm.add_smp($LAST_MATCH_INFO[:no], :in, code)
        when /#{output_smp_pat}/
          pbm.add_smp($LAST_MATCH_INFO[:no], :exp, code)
        end
      end
    end
  end
end
