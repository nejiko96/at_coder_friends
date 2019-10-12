# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # parses constraints
    module ConstraintsParser
      module_function

      def process(pbm)
        pbm.constraints = parse(pbm.desc)
      end

      def parse(desc)
        desc
          .gsub(/[,\\(){}|]/, '')
          .gsub(/(≤|leq?)/i, '≦')
          .scan(/([\da-z_]+)\s*≦\s*(\d+)(?:\^(\d+))?/i)
          .map do |v, sz, k|
            sz = sz.to_i
            sz **= k.to_i if k
            Constraint.new(v, :max, sz)
          end
      end
    end
  end
end
