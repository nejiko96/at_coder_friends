# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'csv'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    CONTEST_LIST_URL = 'https://kenkoooo.com/atcoder/resources/contests.json'
    ACF_HOME = File.expand_path(File.join(__dir__, '..', '..'))
    REGRESSION_HOME = File.join(ACF_HOME, 'regression')
    PAGES_DIR = File.join(REGRESSION_HOME, 'pages')
    PAGES_DIR_FMT = File.join(REGRESSION_HOME, 'pages_%<now>s')
    EMIT_ORG_DIR = File.join(REGRESSION_HOME, 'emit_org')
    EMIT_DIR_FMT = File.join(REGRESSION_HOME, 'emit_%<now>s')
    PERM_CONTEST_LIST = %w[practice apg4b].freeze

    def contest_id_list
      contests = PERM_CONTEST_LIST
      uri = URI.parse(CONTEST_LIST_URL)
      json = Net::HTTP.get(uri)
      contests += JSON.parse(json).map { |h| h['id'] }
      puts "Total #{contests.size} contests"
      contests
    end

    def local_pbm_list
      Dir.glob("#{PAGES_DIR}/**/*.html").map do |pbm_path|
        contest = File.basename(File.dirname(pbm_path))
        q = File.basename(pbm_path, '.html')
        url = "file://#{pbm_path}"
        [contest, q, url]
      end.sort # .take(10)
    end

    def pbm_list_from_file(file)
      dat = File.join(REGRESSION_HOME, file)
      CSV.read(dat, col_sep: "\t", headers: false).map do |contest, q|
        pbm_path = File.join(PAGES_DIR, contest, "#{q}.html")
        url = "file://#{pbm_path}"
        [contest, q, url]
      end
    end
  end
end
