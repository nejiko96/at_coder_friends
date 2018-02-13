# frozen_string_literal: true

module AtCoderFriends
  class Emitter
    SMP_DIR = 'data'

    def initialize(dir)
      @dir = dir
      @smpdir = File.join(@dir, SMP_DIR)
    end

    def emit(pbm)
      Dir.mkdir(@dir) unless Dir.exist?(@dir)
      Dir.mkdir(@smpdir) unless Dir.exist?(@smpdir)
      pbm.smps.each { |smp| out_sample(pbm, smp) }
      pbm.srcs.each { |src| out_source(pbm, src) }
    end

    def out_sample(pbm, smp)
      smpfile = format(
        '%<q>s_%<n>03d.%<ext>s',
        q: pbm.q, n: smp.no, ext: smp.ext
      )
      smppath = File.join(@smpdir, smpfile)
      File.write(smppath, smp.txt)
      puts smpfile
    end

    def out_source(pbm, src)
      srcfile = format(
        '%<q>s.%<ext>s',
        q: pbm.q, ext: src.ext
      )
      srcpath = File.join(@dir, srcfile)
      File.write(srcpath, src.txt)
      puts srcfile
    end
  end
end
