# frozen_string_literal: true

require 'rbconfig'

module AtCoderFriends
  # run tests for the specified program.
  class TestRunner
    include PathUtil

    def initialize(path, config)
      @path, @dir, @prg, @base, @ext, @q = split_prg_path(path)
      @config = config
    end

    # rubocop:disable Metrics/MethodLength
    def run_test(id, infile, outfile, expfile)
      return false unless File.exist?(infile) && File.exist?(expfile)

      puts "==== #{id} ===="
      ec = system("#{test_cmd} < #{infile} > #{outfile}")

      input, result, expected =
        [infile, outfile, expfile].map { |file| File.read(file) }
      puts '-- input --'
      print input
      puts '-- expected --'
      print expected
      puts '-- result --'
      print result
      if !ec
        puts '!!!!! RE !!!!!'
      elsif result != expected
        puts '!!!!! WA !!!!!'
      else
        puts '<< OK >>'
      end
      true
    end
    # rubocop:enable Metrics/MethodLength

    def test_cmd
      cmds = @config['ext_settings'][@ext.downcase]&.dig('test_cmd')
      raise AppError, "test command for .#{@ext} not defined" unless cmds

      os = which_os.to_s
      cmd = cmds[os] || cmds['default']
      raise AppError, "test command for .#{@ext}(#{os}) not defined" unless cmd

      cmd.gsub('{dir}', @dir).gsub('{base}', @base)
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
