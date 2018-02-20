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
      usage 'command or path is not specified.' if args.size < 2
      @config = ConfigLoader.load_config(args[1])
      exec_command(*args)
      STATUS_SUCCESS
    rescue AtCoderFriends::ConfigNotFoundError => e
      warn e.message
      STATUS_ERROR
    rescue StandardError, SyntaxError, LoadError => e
      warn e.message
      warn e.backtrace
      STATUS_ERROR
    rescue SystemExit => e
      e.status
    end

    def usage(msg = nil)
      warn @usage
      warn "error: #{msg}" if msg
      exit STATUS_ERROR
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
      usage e.message
    end

    def handle_exiting_option
      return unless EXITING_OPTIONS.any? { |o| @options.key? o }
      puts AtCoderFriends::VERSION if @options[:version]
      exit STATUS_SUCCESS
    end

    def exec_command(command, path)
      case command
      when 'setup'
        setup(path)
      when 'test-one'
        test_one(path)
      when 'test-all'
        test_all(path)
      when 'submit'
        submit(path)
      else
        usage "unknown command: #{command}"
      end
    end

    def setup(path)
      raise StandardError, "#{path} already exists." if Dir.exist?(path)
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

    def test_one(path)
      TestRunner.new(path).test_one(1)
    end

    def test_all(path)
      vf = Verifier.new(path)
      TestRunner.new(path).test_all
      vf.verify
    end

    def submit(path)
      vf = Verifier.new(path)
      return unless vf.verified?
      ScrapingAgent.new(contest_name(path), @config).submit(path)
      vf.unverify
    end
  end
end
