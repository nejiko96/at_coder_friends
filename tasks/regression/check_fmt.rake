# frozen_string_literal: true

require_relative 'regression'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    def check_fmt
      File.open(log_path('check_fmt.txt'), 'w') do |f|
        local_pbm_list.sort.each do |contest, q, url|
          pbm = scraping_agent(nil, contest).fetch_problem(q, url)
          Parser::Sections.process(pbm)
          fmt = Parser::InputFormat.find_fmt(pbm)
          next unless fmt && !fmt.empty?

          n_fmt = Parser::InputFormat.normalize_fmt(fmt).join("\n")
          Parser::InputFormat.process(pbm)
          res = pbm.formats.map(&:to_s).join("\n")
          f.puts [
            contest, q,
            tsv_escape(fmt),
            tsv_escape(n_fmt),
            tsv_escape(res)
          ].join("\t")
        end
      end
    end

    def tsv_escape(str)
      '"' + str.gsub('"', '""').gsub("\t", ' ') + '"'
    end
  end
end

namespace :regression do
  desc 'checks input format patterns'
  task :check_fmt do
    AtCoderFriends::Regression.check_fmt
  end
end
