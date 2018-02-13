# frozen_string_literal: true

module AtCoderFriends
  DataSample = Struct.new(:no, :ext, :txt)
  SourceSample = Struct.new(:ext, :txt)

  class Problem
    attr_reader :q, :smps, :defs, :srcs
    attr_accessor :desc, :fmt

    def initialize(q)
      @q = q
      @desc = ''
      @fmt = ''
      @smps = []
      @defs = []
      @srcs = []
    end

    def add_smp(no, ext, txt)
      @smps << DataSample.new(no, ext, txt)
    end

    def add_src(ext, src)
      @srcs << SourceSample.new(ext, txt)
    end
  end
end
