# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'mechanize'
require 'at_coder_friends'

module AtCoderFriends
  # tasks for regression test
  module Regression
    module_function

    CONTEST_LIST_URL = 'https://kenkoooo.com/atcoder/resources/contests.json'
    ACF_HOME = File.realpath(File.join(__dir__, '..'))
    REGRESSION_HOME = File.join(ACF_HOME, 'regression')
    PAGES_DIR = File.join(REGRESSION_HOME, 'pages')
    EMIT_ORG_DIR = File.join(REGRESSION_HOME, 'emit_org')
    EMIT_DIR = File.join(REGRESSION_HOME, 'emit')

    def setup
      rmdir_force(PAGES_DIR)
      rmdir_force(EMIT_ORG_DIR)
      contest_id_list.each do |contest|
        begin
          ctx = context(EMIT_ORG_DIR, contest)
          ctx.scraping_agent.fetch_all do |pbm|
            begin
              html_path = File.join(PAGES_DIR, contest, "#{pbm.q}.html")
              create_file(html_path, pbm.html)
              pipeline(ctx, pbm)
            rescue StandardError => e
              p e
            end
          end
        rescue StandardError => e
          p e
        end
        sleep 3
      end
    end

    def check
      emit_dir = EMIT_DIR + Time.now.strftime('_%Y%m%d%H%m')
      rmdir_force(emit_dir)

      pbm_list do |contest, q, url|
        ctx = context(emit_dir, contest)
        pbm = ctx.scraping_agent.fetch_problem(q, url)
        pipeline(ctx, pbm)
      end
      system("diff -r #{EMIT_ORG_DIR} #{emit_dir}")
    end

    def section_list
      agent = Mechanize.new
      list = []
      pbm_list do |contest, q, url|
        page = agent.get(url)
        list += page.search('h3').map do |h3|
          {
            contest: contest,
            q: q,
            text: normalize(h3.content)
          }
        end
      end
      list
        .group_by { |sec| sec[:text] }
        .sort_by { |_, vs| vs.size }
        .reverse
        .each { |k, vs| puts "#{k}(#{vs.size})" }
    end

    def normalize(s)
      s
        .tr('　０-９Ａ-Ｚａ-ｚ', ' 0-9A-Za-z')
        .gsub(/[^一-龠_ぁ-ん_ァ-ヶーa-zA-Z0-9 ]/, '')
        .strip
    end

    def contest_id_list
      @contest_list = begin
        uri = URI.parse(CONTEST_LIST_URL)
        json = Net::HTTP.get(uri)
        contests = JSON.parse(json)
        puts "contests count: #{contests.size}"
        contests.map { |h| h['id'] }
      end
    end

    def pbm_list
      Dir.glob(PAGES_DIR + '/**/*.html').each do |pbm_path|
        contest = File.basename(File.dirname(pbm_path))
        q = File.basename(pbm_path, '.html')
        url = "file://#{pbm_path}"
        yield contest, q, url
      end
    end

    def context(root, contest)
      Context.new({}, File.join(root, contest))
    end

    def rmdir_force(dir)
      FileUtils.rm_r(dir) if Dir.exist?(dir)
    end

    def create_file(path, content)
      dir = File.dirname(path)
      FileUtils.makedirs(dir) unless Dir.exist?(dir)
      File.write(path, content)
    end

    def pipeline(ctx, pbm)
      @parser ||= FormatParser.new
      @rb_gen ||= RubyGenerator.new
      @cxx_gen ||= CxxGenerator.new
      @parser.process(pbm)
      @rb_gen.process(pbm)
      @cxx_gen.process(pbm)
      ctx.emitter.emit(pbm)
    end
  end
end

namespace :regression do
  desc 'setup regression environment'
  task :setup do
    AtCoderFriends::Regression.setup
  end

  desc 'run regression check'
  task :check do
    AtCoderFriends::Regression.check
  end

  desc 'generate section list'
  task :section_list do
    AtCoderFriends::Regression.section_list
  end
end
