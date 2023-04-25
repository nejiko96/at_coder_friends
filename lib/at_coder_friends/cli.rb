# frozen_string_literal: true

require 'optparse'
require 'launchy'

module AtCoderFriends
  # command line interface
  class CLI
    EXITING_OPTIONS = %i[version].freeze
    OPTION_BANNER   =
      <<~TEXT
        Usage:
          at_coder_friends setup        path/contest       # setup contest folder
          at_coder_friends test-one     path/contest/src   # run 1st test case
          at_coder_friends test-all     path/contest/src   # run all test cases
          at_coder_friends submit       path/contest/src   # submit source code
          at_coder_friends check-and-go path/contest/src   # submit source if all tests passed
          at_coder_friends open-contest path/contest/src   # open contest page
        Options:
      TEXT
    STATUS_SUCCESS  = 0
    STATUS_ERROR    = 1

    attr_reader :ctx

    def run(args = ARGV)
      parse_options!(args)
      handle_exiting_option
      raise ParamError, 'command or path is not specified.' if args.size < 2

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
        opts.on('-d', '--debug', 'Display debug info.') do
          @options[:debug] = true
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

    def exec_command(command, path, *args)
      @ctx = Context.new(@options, path)

      mtd = "command_#{command.gsub('-', '_')}"
      raise ParamError, "unknown command: #{command}" unless respond_to?(mtd)

      send(mtd, *args)
      ctx.post_process
    end

    def command_setup
      path = ctx.path
      raise AppError, "#{path} is not empty." \
        if Dir.exist?(path) && !Dir["#{path}/*"].empty?

      ctx.scraping_agent.fetch_all do |pbm|
        Parser::Main.process(pbm)
        ctx.generator.process(pbm)
        ctx.emitter.emit(pbm)
      end
    end

    def command_test_one(id = '001')
      ctx.sample_test_runner.test_one(id)
    end

    def command_test_all
      ctx.sample_test_runner.test_all
      ctx.verifier.verify
    end

    def command_submit
      vf = ctx.verifier
      raise AppError, "#{vf.file} has not been tested." unless vf.verified?

      ctx.scraping_agent.submit
      vf.unverify
      open_submission_list
    end

    def command_check_and_go
      vf = ctx.verifier
      if ctx.sample_test_runner.test_all
        # submit automatically
        ctx.scraping_agent.submit
        vf.unverify
        open_submission_list
      else
        # enable manual submit
        vf.verify
      end
    end

    def command_judge_one(id = '')
      ctx.judge_test_runner.judge_one(id)
    end

    def command_judge_all
      ctx.judge_test_runner.judge_all
    end

    def command_open_contest
      Launchy.open(ctx.scraping_agent.contest_url)
    end

    def open_submission_list
      url = ctx.scraping_agent.contest_url('submissions/me')
      puts "submission status : #{url}"
      Launchy.open(url)
    end
  end
end
