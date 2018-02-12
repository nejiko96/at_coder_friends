# frozen_string_literal: true

require 'optparse'

module AtCoderFriends
  # command line interface
  class CLI
    def run(args = ARGV)
      @options = parse_options!(args)
      handle_show_info_option
      usage 'command or path is not specified.' if args.size < 2
      exec_command(*args)
    end

    def parse_options!(args)
      options = {}
      op = OptionParser.new do |opts|
        opts.banner = 'Usage: at_coder_friends [options] [command] [path]'
        opts.on('-v', '--version') { options[:version] = true }
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
      when 'init'
        Agent.new.generate path
      when 'test-one'
        TestRunner.new(path).test_one 1
      when 'test-all'
        TestRunner.new(path).test_all
      when 'submit'
        Agent.new.submit path
      else
        usage "wrong command: #{command}"
      end
    end
  end
end
