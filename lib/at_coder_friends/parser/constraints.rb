# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # parses constraints
    module Constraints
      module_function

      SECTIONS = [
        Problem::SECTION_IN_FMT,
        Problem::SECTION_IO_FMT,
        Problem::SECTION_CONSTRAINTS
      ].freeze

      def process(pbm)
        str = SECTIONS.reduce('') do |m, key|
          m + (pbm.sections[key]&.content || '')
        end
        constraints = parse(str)
        pbm.constants += constraints
      end

      def parse(str)
        str
          .gsub(/[,\\(){}|]/, '')
          .gsub(/(≤|leq?)/i, '≦')
          .scan(/([\da-z_]+)\s*≦\s*(\d+)(?:\^(\d+))?/i)
          .map do |v, sz, k|
            sz = sz.to_i
            sz **= k.to_i if k
            Problem::Constant.new(v, :max, sz)
          end
      end
    end
  end
end
