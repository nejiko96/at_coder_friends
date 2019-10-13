# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # entry point for parsing problem description
    module Main
      module_function

      def process(pbm)
        PageParser.process(pbm)
        FormatParser.process(pbm)
        ConstraintsParser.process(pbm)
      end
    end
  end
end
