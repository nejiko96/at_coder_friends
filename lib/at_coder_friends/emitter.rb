# frozen_string_literal: true

module AtCoderFriends
  SMP_DIR = 'data'.freeze

  class Emitter
    def initialize(path)
      @path = path
      @smpdir = Pathname.new(path).join(SMP_DIR)
    end

    def emit(pbm)
      Dir.mkdir(@smpdir) unless Dir.exist?(@smpdir)
      pbm.smps.each { |smp| out_sample(smp) }
      pbm.srcs.each { |smp| out_source(smp) }
    end

    def out_sample(smp)
    end

    def out_source(src)
    end
  end
end
