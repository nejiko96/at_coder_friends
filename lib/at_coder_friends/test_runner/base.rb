# frozen_string_literal: true

require 'colorize'
require 'rbconfig'

module AtCoderFriends
  module TestRunner
    # run tests for the specified program.
    class Base
      include PathUtil

      attr_reader :ctx, :path, :dir, :prg, :base, :ext, :q

      def initialize(ctx)
        @ctx = ctx
        @path, @dir, @prg, @base, @ext, @q = split_prg_path(ctx.path)
      end

      def config
        ctx.config
      end

      def test_cmd
        @test_cmd ||= begin
          cmds = config.dig('ext_settings', ext, 'test_cmd')
          cmd = cmds && (cmds[which_os.to_s] || cmds['default'])
          cmd && cmd.gsub('{dir}', dir).gsub('{base}', base)
        end
      end

      def test_loc
        test_cmd ? 'local' : 'remote'
      end

      def test_mtd
        test_cmd ? :local_test : :remote_test
      end

      def run_test(id, infile, outfile, expfile)
        return false unless File.exist?(infile) && File.exist?(expfile)

        puts "==== #{id} ===="

        makedirs_unless(File.dirname(outfile))
        is_success = send(test_mtd, infile, outfile)
        show_result(
          is_success,
          File.read(infile),
          File.read(outfile),
          File.read(expfile)
        )
        true
      end

      def local_test(infile, outfile)
        system("#{test_cmd} < #{infile} > #{outfile}")
      end

      def remote_test(infile, outfile)
        is_success, result = call_remote_test(infile)
        File.write(outfile, result)
        is_success
      end

      def call_remote_test(infile)
        res = ctx.scraping_agent.code_test(infile)
        (res && res['Result']) || (return [false, 'Remote test failed.'])

        puts "Exit code: #{res.dig('Result', 'ExitCode')}"
        puts "Time: #{res.dig('Result', 'TimeConsumption')}ms"
        puts "Memory: #{res.dig('Result', 'MemoryConsumption')}KB"

        res.dig('Result', 'ExitCode').zero? || (return [false, res['Stderr']])
        [true, res['Stdout']]
      end

      def show_result(is_success, input, result, expected)
        print detail_str(input, result, expected)
        puts result_str(is_success, result, expected)
      end

      def detail_str(input, result, expected)
        ret = ''
        ret += "-- input --\n"
        ret += input
        ret += "-- expected --\n"
        ret += expected
        ret += "-- result --\n"
        ret += result
        ret
      end

      def result_str(is_success, result, expected)
        if !is_success
          '!!!!! RE !!!!!'.red
        elsif result != expected
          '!!!!! WA !!!!!'.red
        else
          '<< OK >>'.green
        end
      end

      def which_os
        @which_os ||= begin
          case RbConfig::CONFIG['host_os']
          when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
            :windows
          when /darwin|mac os/
            :macosx
          when /linux/
            :linux
          when /solaris|bsd/
            :unix
          else
            :unknown
          end
        end
      end
    end
  end
end
