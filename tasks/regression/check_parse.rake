# frozen_string_literal: true

require_relative 'regression'
require 'at_coder_friends'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    def check_parse(arg)
      arg ||= 'fmt,smp,int'
      list = local_pbm_list.map do |contest, q, url|
        pbm = scraping_agent(nil, contest).fetch_problem(q, url)
        Parser::Main.process(pbm)
        tbl = {
          'fmt' => !fmt?(pbm),
          'smp' => pbm.samples.all? { |smp| smp.txt.empty? },
          'int' => pbm.options.interactive,
          'bin' => pbm.options.binary_values
        }
        [contest, q, tbl.values_at(*arg.split(','))]
      end
      report(list)
    end

    def fmt?(pbm)
      [Problem::SECTION_IN_FMT, Problem::SECTION_IO_FMT]
        .any? { |key| pbm.sections[key]&.code_block&.size&.positive? }
    end

    def report(list)
      list
        .select { |_, _, flags| flags.any? }
        .map { |c, q, flags| [c, q, flags.map { |f| f_to_s(f) }] }
        .sort
        .each { |args| puts args.flatten.join("\t") }
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
  task :check_parse, ['flags'] do |_, args|
    flags = args[:flags]
    AtCoderFriends::Regression.check_parse flags
  end
end
