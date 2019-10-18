# frozen_string_literal: true

module AtCoderFriends
  module Scraping
    # fetch problems from tasks page
    module Tasks
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
        page.search('br').each { |br| br.replace("\n") }
        Problem.new(q) do |pbm|
          pbm.page = page
        end
      end
    end
  end
end
