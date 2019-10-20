# frozen_string_literal: true

module AtCoderFriends
  module Generator
    # entry point of source generation
    class Main
      attr_reader :ctx

      def initialize(ctx)
        @ctx = ctx
        @cache = {}
      end

      def process(pbm)
        generators = ctx.config.dig('generators') || []
        generators.each do |gen_name|
          gen_obj = load_obj(gen_name)
          gen_obj.process(pbm)
        end
      end

      def load_obj(gen_name)
        @cache[gen_name] ||= begin
          gen_class = load_class(gen_name)
          gen_cnf = config_for(gen_name)
          gen_class.new(gen_cnf)
        end
      end

      def load_class(gen_name)
        unless AtCoderFriends::Generator.const_defined?(gen_name)
          require "at_coder_friends/generator/#{to_snake(gen_name)}"
        end
        AtCoderFriends::Generator.const_get(gen_name)
      rescue LoadError
        raise AppError, "plugin load error : generator #{gen_name} not found."
      end

      def config_for(gen_name)
        ctx.config.dig('generator_settings', gen_name) || {}
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
