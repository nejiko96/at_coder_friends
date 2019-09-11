# frozen_string_literal: true

require 'rbconfig'

module AtCoderFriends
  # run tests for the specified program.
  class TestRunner
    include PathUtil

    def initialize(path, config)
      @contest = contest_name(path)
      @path, @dir, @prg, @base, @ext, @q = split_prg_path(path)
      @config = config
    end

    # rubocop:disable Metrics/MethodLength
    def run_test(id, infile, outfile, expfile)
      return false unless File.exist?(infile) && File.exist?(expfile)

      puts "==== #{id} (#{test_loc}) ===="

      success = send(test_mtd, infile, outfile)
      input, result, expected =
        [infile, outfile, expfile].map { |file| File.read(file) }

      puts '-- input --'
      print input
      puts '-- expected --'
      print expected
      puts '-- result --'
      print result
      if !success
        puts '!!!!! RE !!!!!'
      elsif result != expected
        puts '!!!!! WA !!!!!'
      else
        puts '<< OK >>'
      end
      true
    end
    # rubocop:enable Metrics/MethodLength

    def test_loc
      test_cmd ? 'local' : 'remote'
    end

    def test_mtd
      test_cmd ? :local_test : :remote_test
    end

    def local_test(infile, outfile)
      system("#{test_cmd} < #{infile} > #{outfile}")
    end

    def remote_test(infile, outfile)
      agent = ScrapingAgent.new(@contest, @config)
      res = agent.code_test(@path, infile)
      unless res && res['Result']
        File.write(outfile, 'Remote test failed.')
        return false
      end
      puts "Exit code: #{res.dig('Result', 'ExitCode')}"
      puts "Time: #{res.dig('Result', 'TimeConsumption')}ms"
      puts "Memory: #{res.dig('Result', 'MemoryConsumption')}KB"
      if res.dig('Result', 'ExitCode') != 0
        File.write(outfile, res['Stderr'])
        return false
      end
      File.write(outfile, res['Stdout'])
      true
    end

    def test_cmd
      @test_cmd ||= begin
        cmds = @config.dig('ext_settings', @ext, 'test_cmd')
        cmd = cmds && (cmds[which_os.to_s] || cmds['default'])
        return nil unless cmd

        cmd.gsub('{dir}', @dir).gsub('{base}', @base)
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
