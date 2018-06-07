# frozen_string_literal: true

require 'optparse'

module AtCoderFriends
  # command line interface
  class CLI
    include PathUtil

    EXITING_OPTIONS = %i[version].freeze
    OPTION_BANNER =
      <<~TEXT
        Usage:
          at_coder_friends setup    path/contest       # setup contest folder
          at_coder_friends test-one path/contest/src   # run 1st test case
          at_coder_friends test-all path/contest/src   # run all test cases
          at_coder_friends submit   path/contest/src   # submit source code
        Options:
      TEXT
    STATUS_SUCCESS  = 0
    STATUS_ERROR    = 1

    def run(args = ARGV)
      parse_options!(args)
      handle_exiting_option
      raise ParamError, 'command or path is not specified.' if args.size < 2
      @config = ConfigLoader.load_config(args[1])
      exec_command(*args)
      STATUS_SUCCESS
    rescue AtCoderFriends::ParamError => e
      warn @usage
      warn "error: #{e.message}"
      STATUS_ERROR
    rescue AtCoderFriends::AppError => e
      warn e.message
      STATUS_ERROR
    rescue SystemExit => e
      e.status
    end

    def parse_options!(args)
      op = OptionParser.new do |opts|
        opts.banner = OPTION_BANNER
        opts.on('-v', '--version', 'Display version.') do
          @options[:version] = true
        end
      end
      @usage = op.to_s
      @options = {}
      op.parse!(args)
    rescue OptionParser::InvalidOption => e
      raise ParamError, e.message
    end

    def handle_exiting_option
      return unless EXITING_OPTIONS.any? { |o| @options.key? o }
      puts AtCoderFriends::VERSION if @options[:version]
      exit STATUS_SUCCESS
    end

    def exec_command(command, path, id = nil)
      case command
      when 'setup'
        setup(path)
      when 'test-one'
        test_one(path, id)
      when 'test-all'
        test_all(path)
      when 'submit'
        submit(path)
      when 'judge-one'
        judge_one(path, id)
      when 'judge-all'
        judge_all(path)
      else
        raise ParamError, "unknown command: #{command}"
      end
    end

    def setup(path)
      raise AppError, "#{path} is not empty." \
        if Dir.exist?(path) && !Dir["#{path}/*"].empty?
      agent = ScrapingAgent.new(contest_name(path), @config)
      parser = FormatParser.new
      rb_gen = RubyGenerator.new
      cxx_gen = CxxGenerator.new
      emitter = Emitter.new(path)
      agent.fetch_all do |pbm|
        parser.process(pbm)
        rb_gen.process(pbm)
        cxx_gen.process(pbm)
        emitter.emit(pbm)
      end
    end

    def test_one(path, id)
      id ||= 1
      SampleTestRunner.new(path).test_one(id)
    end

    def test_all(path)
      SampleTestRunner.new(path).test_all
      Verifier.new(path).verify
    end

    def submit(path)
      vf = Verifier.new(path)
      raise AppError, "#{vf.file} has not been tested." unless vf.verified?
      ScrapingAgent.new(contest_name(path), @config).submit(path)
      vf.unverify
    end

    def judge_one(path, id)
      id ||= ''
      JudgeTestRunner.new(path).judge_one(id)
    end

    def judge_all(path)
      JudgeTestRunner.new(path).judge_all
    end
  end
end
