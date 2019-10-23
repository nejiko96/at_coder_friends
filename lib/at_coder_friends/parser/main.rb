# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # entry point for parsing problem description
    module Main
      module_function

      def process(pbm)
        Sections.process(pbm)
        SampleData.process(pbm)
        InputFormat.process(pbm)
        Constraints.process(pbm)
        Modulo.process(pbm)
        Interactive.process(pbm)
        Binary.process(pbm)
      end
    end
  end
end
