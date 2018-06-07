# frozen_string_literal: true

require 'rbconfig'

module AtCoderFriends
  # run tests for the specified program.
  class TestRunner
    include PathUtil

    def initialize(path)
      @path, @dir, @prg, @base, @ext, @q = split_prg_path(path)
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def run_test(id, infile, outfile, expfile)
      return false unless File.exist?(infile) && File.exist?(expfile)

      puts "==== #{id} ===="
      ec = system("#{edit_cmd} < #{infile} > #{outfile}")

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
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    # rubocop:disable Metrics/MethodLength
    def edit_cmd
      case @ext
      when 'java'
        "java -cp #{@dir} Main"
      when 'rb'
        "ruby #{@dir}/#{@base}.rb"
      when 'cs'
        case which_os
        when :windows
          "#{@dir}/#{@base}.exe"
        else
          "mono #{@dir}/#{@base}.exe"
        end
      else # c, cxx
        case which_os
        when :windows
          "#{@dir}/#{@base}.exe"
        else
          "#{@dir}/#{@base}"
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    def which_os
      @os ||= begin
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
