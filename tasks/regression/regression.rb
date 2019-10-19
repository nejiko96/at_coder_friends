# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'csv'
require 'mechanize'
require 'at_coder_friends'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    CONTEST_LIST_URL = 'https://kenkoooo.com/atcoder/resources/contests.json'
    REGRESSION_HOME =
      File.realpath(File.join(__dir__, '..', '..', 'regression'))
    PAGES_DIR = File.join(REGRESSION_HOME, 'pages')
    EMIT_ORG_DIR = File.join(REGRESSION_HOME, 'emit_org')
    EMIT_DIR_FMT = File.join(REGRESSION_HOME, 'emit_%<now>s')

    def contest_id_list
      uri = URI.parse(CONTEST_LIST_URL)
      json = Net::HTTP.get(uri)
      contests = JSON.parse(json)
      puts "Total #{contests.size} contests"
      contests.map { |h| h['id'] }
    end

    def local_pbm_list
      Dir.glob(PAGES_DIR + '/**/*.html').map do |pbm_path|
        contest = File.basename(File.dirname(pbm_path))
        q = File.basename(pbm_path, '.html')
        url = "file://#{pbm_path}"
        [contest, q, url]
      end
    end

    def pbm_list_from_file(file)
      dat = File.join(REGRESSION_HOME, file)
      CSV.read(dat, col_sep: "\t", headers: false).map do |contest, q|
        pbm_path = File.join(PAGES_DIR, contest, "#{q}.html")
        url = "file://#{pbm_path}"
        [contest, q, url]
      end
    end

    def scraping_agent(root, contest)
      @ctx = Context.new({}, File.join(root, contest))
      @ctx.scraping_agent
    end

    def agent
      @agent ||= Mechanize.new
    end

    def pipeline(pbm)
      Parser::Main.process(pbm)
      @ctx.generator.process(pbm)
      @ctx.emitter.emit(pbm)
    end

    def rmdir_force(dir)
      FileUtils.rm_r(dir) if Dir.exist?(dir)
    end
  end
end
