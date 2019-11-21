# frozen_string_literal: true

require 'mechanize'
require 'at_coder_friends'
require_relative 'list_handler'
require_relative 'report_handler'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    def scraping_agent(root, contest)
      root ||= REGRESSION_HOME
      @ctx = Context.new({}, File.join(root, contest))
      @ctx.scraping_agent
    end

    def local_scraping_agent(root, contest)
      scraping_agent(root, contest)
        .tap { |sa| sa.agent.pre_connect_hooks.clear }
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
