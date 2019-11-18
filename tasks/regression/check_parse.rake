# frozen_string_literal: true

require_relative 'regression'
require 'at_coder_friends'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    def check_parse
      list = local_pbm_list.map do |contest, q, url|
        pbm = local_scraping_agent(nil, contest).fetch_problem(q, url)
        Parser::Main.process(pbm)
        flags = [
          !fmt?(pbm),
          pbm.samples.all? { |smp| smp.txt.empty? },
          pbm.options.interactive
        ]
        [contest, q, flags]
      end
      report(list, 'check_parse.txt')
    end

    def check_bin
      list = local_pbm_list.map do |contest, q, url|
        pbm = local_scraping_agent(nil, contest).fetch_problem(q, url)
        Parser::Main.process(pbm)
        flags = [pbm.options.binary_values]
        [contest, q, flags]
      end
      report(list, 'check_bin.txt')
    end

    def fmt?(pbm)
      fmt = Parser::InputFormat.find_fmt(pbm)
      fmt && !fmt.empty?
    end

    def report(list, file)
      File.open(report_path(file), 'w') do |f|
        list
          .select { |_, _, flags| flags.any? }
          .map { |c, q, flags| [c, q, flags.map { |flg| f_to_s(flg) }] }
          .each { |args| f.puts args.flatten.join("\t") }
      end
    end

    def f_to_s(f)
      if f.is_a?(Array)
        f
      else
        f ? '◯' : '-'
      end
    end
  end
end

namespace :regression do
  desc 'checks page parse result'
  task :check_parse do
    AtCoderFriends::Regression.check_parse
  end

  desc 'checks binary problem parse result'
  task :check_bin do
    AtCoderFriends::Regression.check_bin
  end
end
