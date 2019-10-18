# frozen_string_literal: true

module AtCoderFriends
  module Generator
    # entry point of source generation
    class Main
      attr_reader :ctx

      def initialize(ctx)
        @ctx = ctx
      end

      def process(pbm)
        RubyBuiltin.new.process(pbm)
        CxxBuiltin.new.process(pbm)
      end
    end
  end
end
