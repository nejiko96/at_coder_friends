# frozen_string_literal: true

require 'optparse'

module AtCoderFriends
  # command line interface
  class CLI
    class Finished < RuntimeError; end

    EXITING_OPTIONS = %i[version].freeze
    STATUS_SUCCESS  = 0
    STATUS_ERROR    = 1

    def run(args = ARGV)
      @options = parse_options!(args)
      handle_exiting_option
      usage 'command or path is not specified.' if args.size < 2
      @config = ConfigLoader.load_config(args[1])
      exec_command(*args)
    rescue AtCoderFriends::ConfigNotFoundError => e
      warn e.message
      STATUS_ERROR
    rescue Finished
      STATUS_SUCCESS
    end

    def parse_options!(args)
      options = {}
      op = OptionParser.new do |opts|
        opts.banner = 'Usage: at_coder_friends [options] [command] [path]'
        opts.on('-v', '--version', 'Display version.') do
          options[:version] = true
        end
      end
      self.class.class_eval do
        define_method(:usage) do |msg = nil|
          puts op.to_s
          puts "error: #{msg}" if msg
          exit 1
        end
      end
      op.parse!(args)
      options
    rescue OptionParser::InvalidOption => e
      usage e.message
    end

    def handle_exiting_option
      return unless EXITING_OPTIONS.any? { |o| @options.key? o }
      puts AtCoderFriends::VERSION if @options[:version]
      raise Finished
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
        usage "wrong command: #{command}"
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

    def contest_name(path)
      dir = File.file?(path) ? File.dirname(path) : path
      File.basename(dir)
    end
  end
end
