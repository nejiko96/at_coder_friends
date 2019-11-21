# frozen_string_literal: true

require_relative 'regression'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    def check_fmt
      File.open(report_path('check_fmt.txt'), 'wb') do |f|
        local_pbm_list.each do |contest, q, url|
          next unless (res = process_fmt(contest, q, url))

          f.puts [
            contest, q, *res.map { |s| tsv_escape(s) }
          ].join("\t")
        end
      end
    end

    def process_fmt(contest, q, url)
      pbm = local_scraping_agent(nil, contest).fetch_problem(q, url)
      Parser::Sections.process(pbm)
      fmt = Parser::InputFormat.find_fmt(pbm)
      return unless fmt && !fmt.empty?

      n_fmt = Parser::InputFormat.normalize_fmt(fmt).join("\n")
      Parser::InputFormat.process(pbm)
      res = pbm.formats_raw.map(&:to_s).join("\n")
      [fmt, n_fmt, res]
    end
  end
end

namespace :regression do
  desc 'checks input format patterns'
  task :check_fmt do
    AtCoderFriends::Regression.check_fmt
  end
end
