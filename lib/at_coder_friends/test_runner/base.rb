# frozen_string_literal: true

require 'colorize'
require 'rbconfig'

module AtCoderFriends
  module TestRunner
    # run tests for the specified program.
    class Base
      include PathUtil
      STATUS_STR = {
        OK: '<< OK >>'.green,
        WA: '!!!!! WA !!!!!'.red,
        RE: '!!!!! RE !!!!!'.red
      }

      attr_reader :ctx, :path, :dir, :prg, :base, :ext, :q

      def initialize(ctx)
        @ctx = ctx
        @path, @dir, @prg, @base, @ext, @q = split_prg_path(ctx.path)
        @detail = true
      end

      def test_cmd
        @test_cmd ||= begin
          cmds = ctx.config.dig('ext_settings', ext, 'test_cmd')
          cmd = cmds && (cmds[which_os.to_s] || cmds['default'])
          cmd&.gsub('{dir}', dir)&.gsub('{base}', base)
        end
      end

      def test_loc
        test_cmd ? 'local' : 'remote'
      end

      def test_mtd
        test_cmd ? :local_test : :remote_test
      end

      def run_test(id, infile, outfile, expfile)
        puts "==== #{id} ===="
        return false unless check_file(infile, outfile, expfile)

        is_success = send(test_mtd, infile, outfile)
        input = File.read(infile)
        result = File.read(outfile)
        expected = File.read(expfile)
        status = check_status(is_success, result, expected)
        print detail_str(input, result, expected) if @detail
        puts STATUS_STR[status]
        status == :OK
      end

      def check_file(infile, outfile, expfile)
        unless File.exist?(infile)
          puts "#{File.basename(infile)} not found."
          return false
        end
        unless File.exist?(expfile)
          puts "#{File.basename(expfile)} not found."
          return false
        end
        makedirs_unless(File.dirname(outfile))
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

      def check_status(is_success, result, expected)
        if !is_success
          :RE
        elsif result != expected
          :WA
        else
          :OK
        end
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
