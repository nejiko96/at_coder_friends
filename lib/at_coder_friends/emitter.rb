# frozen_string_literal: true

require 'fileutils'

module AtCoderFriends
  class Emitter
    SMP_DIR = 'data'

    def initialize(dir)
      @srcdir = dir
      @smpdir = File.join(dir, SMP_DIR)
    end

    def emit(pbm)
      pbm.smps.each { |smp| emit_sample(pbm, smp) }
      pbm.srcs.each { |src| emit_source(pbm, src) }
    end

    def emit_sample(pbm, smp)
      FileUtils.mkdirs(@smpdir) unless Dir.exist?(@smpdir)
      smpfile = format(
        '%<q>s_%<n>03d.%<ext>s',
        q: pbm.q, n: smp.no, ext: smp.ext
      )
      smppath = File.join(@smpdir, smpfile)
      File.write(smppath, smp.txt)
      puts smpfile
    end

    def emit_source(pbm, src)
      FileUtils.mkdirs(@srcdir) unless Dir.exist?(@srcdir)
      srcfile = format(
        '%<q>s.%<ext>s',
        q: pbm.q, ext: src.ext
      )
      srcpath = File.join(@srcdir, srcfile)
      File.write(srcpath, src.txt)
      puts srcfile
    end
  end
end
