# frozen_string_literal: true

module AtCoderFriends
  SampleData = Struct.new(:no, :ext, :txt) do
    def initialize(no, ext, txt)
      super(no.to_i, ext, txt)
    end
  end

  InputDef = Struct.new(:container, :item, :names, :size) do
    def initialize(container, item, names, size = [])
      super(container, item, names, size)
    end
  end

  Constraint = Struct.new(:name, :type, :value)

  SourceCode = Struct.new(:ext, :txt)

  # holds problem information
  class Problem
    attr_reader :q, :smps, :srcs
    attr_accessor :page, :desc, :fmt, :defs, :constraints

    def initialize(q)
      @q = q
      @page = nil
      @desc = ''
      @fmt = ''
      @smps = []
      @defs = []
      @constraints = []
      @srcs = []
      yield self if block_given?
    end

    def url
      page.uri.to_s
    end

    def add_smp(no, ext, txt)
      @smps << SampleData.new(no, ext, txt)
    end

    def add_src(ext, txt)
      @srcs << SourceCode.new(ext, txt)
    end
  end
end
