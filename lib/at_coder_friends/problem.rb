# frozen_string_literal: true

module AtCoderFriends
  # holds problem information
  class Problem
    SECTION_STATEMENT = 'STATEMENT'
    SECTION_IN_FMT = 'INPUT_FORMAT'
    SECTION_OUT_FMT = 'OUTPUT_FORMAT'
    SECTION_IO_FMT = 'INOUT_FORMAT'
    SECTION_CONSTRAINTS = 'CONSTRAINTS'
    SECTION_IN_SMP = 'INPUT_SAMPLE_%<no>s'
    SECTION_IN_SMP_PAT = /^INPUT_SAMPLE_(?<no>\d+)$/.freeze
    SECTION_OUT_SMP = 'OUTPUT_SAMPLE_%<no>s'
    SECTION_OUT_SMP_PAT = /^OUTPUT_SAMPLE_(?<no>\d+)$/.freeze
    SECTION_IO_SMP = 'INOUT_SAMPLE'

    SampleData = Struct.new(:no, :ext, :txt)

    InputFormat = Struct.new(:container, :item, :names, :size) do
      def initialize(container, item, names, size = [])
        super(container, item, names, size)
      end
    end

    Constant = Struct.new(:name, :type, :value)

    Options = Struct.new(:interactive, :binary_values)

    SourceCode = Struct.new(:ext, :txt)

    attr_reader :q, :samples, :sources, :options
    attr_accessor :page, :sections, :formats, :constants

    def initialize(q, page = Mechanize::Page.new)
      @q = q
      @page = page
      @sections = {}
      @samples = []
      @formats = []
      @constants = []
      @options = Options.new
      @sources = []
      yield self if block_given?
    end

    def url
      @url ||= page.uri.to_s
    end

    def body_content
      @body_content ||= page.search('body')[0]&.content
    end

    def add_smp(no, ext, txt)
      @samples << SampleData.new(no, ext, txt)
    end

    def add_src(ext, txt)
      @sources << SourceCode.new(ext, txt)
    end
  end
end
