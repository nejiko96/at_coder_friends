# frozen_string_literal: true

require_relative 'regression'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    def check_fmt
      open_report('check_fmt.txt') do |f|
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
      Parser::SampleData.process(pbm)
      fmt1 = Parser::InputFormat.find_fmt(pbm)
      return unless fmt1 && !fmt1.empty?

      fmt2 = Parser::InputFormat.normalize_fmt(fmt1).join("\n")
      Parser::InputFormat.process(pbm)
      Parser::InputType.process(pbm)
      inpdefs = pbm.formats_src
      fmt3 = inpdefs.map(&:to_s).join("\n")
      fmt4 = inpdefs.any? { |inpdef| inpdef.cols.empty? } ? '○' : ''
      [fmt1, fmt2, fmt3, fmt4]
    end
  end
end

namespace :regression do
  desc 'checks input format patterns'
  task :check_fmt do
    AtCoderFriends::Regression.check_fmt
  end
end
