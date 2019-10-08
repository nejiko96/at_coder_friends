# frozen_string_literal: true

require 'at_coder_friends'
require 'net/http'
require 'uri'
require 'json'

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

      pbm_list do |contest, q, pbm_path|
        ctx = context(emit_dir, contest)
        pbm = ctx.scraping_agent.fetch_problem(q, 'file://' + pbm_path)
        pipeline(ctx, pbm)
      end
      system("diff -r #{EMIT_ORG_DIR} #{emit_dir}")
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
        yield contest, q, pbm_path
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
end
