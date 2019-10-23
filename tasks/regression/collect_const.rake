# frozen_string_literal: true

require_relative 'regression'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    def collect_mod
      local_pbm_list.each do |contest, q, url|
        page = agent.get(url)
        body = page.body.force_encoding('utf-8')
        ms = body.scan(
          /(.{,30}(?:で割った|modulo|mod\b|divided by|dividing by).{,30})/mi
        )
        next if ms.empty?

        s = ms[0][0].delete("\r\n\t\"")
        puts [contest, q, s].join("\t")
      end
    end

    def check_mod
      list = local_pbm_list.flat_map do |contest, q, url|
        pbm = scraping_agent(REGRESSION_HOME, contest).fetch_problem(q, url)
        Parser::Sections.process(pbm)
        Parser::Modulo.process(pbm)
        pbm.constants.map do |cnst|
          [contest, q, cnst.value]
        end
      end
      list.each { |args| puts args.join("\t") }
    end

    def merge_list(file1, file2)
      tbl = {}
      list_from_file(file1).each do |contest, q, txt|
        key = "#{contest}\t#{q}"
        (tbl[key] ||= {})[:txt1] = txt
      end
      list_from_file(file2).each do |contest, q, txt|
        key = "#{contest}\t#{q}"
        (tbl[key] ||= {})[:txt2] ||= ''
        txt ||= ''
        tbl[key][:txt2] += (txt + "\t")
      end
      tbl.each do |k, v|
        puts [k, v[:txt1], v[:txt2]].join("\t")
      end
    end

    def list_from_file(file)
      Encoding.default_external = 'utf-8'
      dat = File.join(ACF_HOME, file)
      CSV.read(dat, col_sep: "\t", headers: false)
    end
  end
end

namespace :regression do
  desc 'list all mod values'
  task :collect_mod do
    AtCoderFriends::Regression.collect_mod
  end

  desc 'check extracted mod values'
  task :check_mod do
    AtCoderFriends::Regression.check_mod
  end

  desc 'merge list'
  task :merge_list, ['file1', 'file2'] do |_, args|
    AtCoderFriends::Regression.merge_list args[:file1], args[:file2]
  end
end
