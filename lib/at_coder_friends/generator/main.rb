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
        generators = ctx.config.dig('generators') || []
        generators.each do |gen_name|
          gen_class = AtCoderFriends::Generator.const_get(gen_name)
          gen_obj = gen_class.new
          gen_obj.process(pbm)
        end
      end
    end
  end
end
