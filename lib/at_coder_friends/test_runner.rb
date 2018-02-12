# frozen_string_literal: true

module AtCoderFriends
  class TestRunner
    def initialize(path)
      @path = path
      @dir, @prog = File.split(@path)
      @base, @ext = @prog.split('.')
    end

    def test_all
      puts "***** test_all #{@prog} *****"
      1.upto(999) do |i|
        break unless test(i)
      end
      Verifier.new(@path).verify
    end

    def test_one(n)
      puts "***** test_one #{@prog} *****"
      test(n)
    end

    def test(n)
      q = @base.split('_')[0]
      cs = format('%<q>s_%<n>03d', q: q, n: n)
      csbase = "#{@dir}/data/#{cs}"
      infile = "#{csbase}.in"
      outfile = "#{csbase}.out"
      expfile = "#{csbase}.exp"

      return false unless File.exist?(infile) && File.exist?(expfile)

      cmd = edit_cmd
      ec = system("#{cmd} < #{infile} > #{outfile}")

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
      host_os = RbConfig::CONFIG['host_os']
      case @ext
      when 'java'
        "java -cp #{@dir} Main"
      when 'rb'
        "ruby #{@dir}/#{@base}.rb"
      when 'cs'
        case host_os
        when /mingw/
          "#{@dir}/#{@base}.exe"
        else
          "mono #{@dir}/#{@base}.exe"
        end
      else # c, cxx
        case host_os
        when /mingw/
          "#{@dir}/#{@base}.exe"
        else
          "#{@dir}/#{@base}"
        end
      end
    end
  end
end
