# frozen_string_literal: true

module AtCoderFriends
  # Holds applicaion global information
  # - command line options
  # - target path
  # - configuration
  # - application modules
  class Context
    attr_reader :options, :path

    def initialize(options, path)
      @options = options
      @path = File.expand_path(path)
    end

    def config
      @config ||= ConfigLoader.load_config(self)
    end

    def scraping_agent
      @scraping_agent ||= Scraping::Agent.new(self)
    end

    def sample_test_runner
      @sample_test_runner ||= TestRunner::Sample.new(self)
    end

    def judge_test_runner
      @judge_test_runner ||= TestRunner::Judge.new(self)
    end

    def verifier
      @verifier ||= Verifier.new(self)
    end

    def emitter
      @emitter ||= Emitter.new(self)
    end

    def post_process
      @scraping_agent&.save_session
    end
  end
end
