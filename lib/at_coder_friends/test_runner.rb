# frozen_string_literal: true

require 'rbconfig'

module AtCoderFriends
  # run tests for the specified program.
  class TestRunner
    SMP_DIR = 'data'

    def initialize(path)
      @path = path
      @dir, @prog = File.split(@path)
      @base, @ext = @prog.split('.')
      @q = @base.split('_')[0]
      @smpdir = File.join(@dir, SMP_DIR)
    end

    def test_all
      puts "***** test_all #{@prog} *****"
      1.upto(999) do |i|
        break unless test(i)
      end
    end

    def test_one(n)
      puts "***** test_one #{@prog} *****"
      test(n)
    end

    def test(n)
      cs = format('%<q>s_%<n>03d', q: @q, n: n)
      basename = "#{@smpdir}/#{cs}"
      infile = "#{basename}.in"
      outfile = "#{basename}.out"
      expfile = "#{basename}.exp"

      return false unless File.exist?(infile) && File.exist?(expfile)

      ec = system("#{edit_cmd} < #{infile} > #{outfile}")

      input = File.read(infile)
      result = File.read(outfile)
      expected = File.read(expfile)

      puts "==== #{cs} ===="
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
