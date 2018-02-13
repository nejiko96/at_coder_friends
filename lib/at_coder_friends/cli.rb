# frozen_string_literal: true

require 'optparse'

module AtCoderFriends
  # command line interface
  class CLI
    def run(args = ARGV)
      @options = parse_options!(args)
      handle_show_info_option
      usage 'command or path is not specified.' if args.size < 2
      @config = ConfigLoader.load_config(dir)
      exec_command(*args)
    end

    def parse_options!(args)
      options = {}
      op = OptionParser.new do |opts|
        opts.banner = 'Usage: at_coder_friends [options] [command] [path]'
        opts.on('-v', '--version', 'Display version.') { options[:version] = true }
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

    def handle_show_info_option
      if @options[:version]
        puts AtCoderFriends::VERSION
        exit 0
      end
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
      unless File.directory?(path)
        puts "#{path} is not a directory."
        return
      end
      unless Dir.empty?(path)
        puts "#{path} is not empty."
        return
      end
      ScrapingAgent.new(contest_name(path), @config).fetch_all do |pbm|
        InputParser.new.parse(pbm)
        RubyGenerator.new.generate(pbm)
        CxxGenerator.new.generate(pbm)
        Emitter.new(path).emit(pbm)
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
      dir = File.directory?(path) ? path : File.dirname(path)
      File.basename(dir)
    end
  end
end
