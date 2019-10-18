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
        generators.each do |camel_name|
          gen_class = load_generator(camel_name)
          gen_obj = gen_class.new
          gen_obj.process(pbm)
        end
      end

      def load_generator(camel_name)
        unless AtCoderFriends::Generator.const_defined?(camel_name)
          snake_name = to_snake(camel_name)
          require "at_coder_friends/generator/#{snake_name}"
        end
        AtCoderFriends::Generator.const_get(camel_name)
      rescue LoadError
        raise AppError, "plugin load error : generator #{camel_name} not found."
      end

      def to_snake(str)
        str
          .gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end
    end
  end
end
