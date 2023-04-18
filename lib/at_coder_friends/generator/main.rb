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
        generators = ctx.config['generators'] || []
        generators.each do |gen_name|
          gen_obj = load_obj(gen_name)
          gen_obj.process(pbm)
        rescue StandardError => e
          puts "an error occurred in generator:#{gen_name}."
          puts e.to_s
          puts e.backtrace
        end
      end

      def load_obj(gen_name)
        @cache[gen_name] ||= begin
          cls_name = gen_name.split('_')[0]
          gen_class = load_class(cls_name)
          gen_cnf = config_for(gen_name)
          gen_class.new(gen_cnf)
        end
      end

      def load_class(gen_name)
        snake_gen_name = to_snake(gen_name)
        require "at_coder_friends/generator/#{snake_gen_name}" unless AtCoderFriends::Generator.const_defined?(gen_name)
        AtCoderFriends::Generator.const_get(gen_name)
      rescue LoadError
        raise AppError, <<~MSG
          Error: Failed to load plugin.
          The '#{gen_name}' plugin could not be found. To use this plugin, please install the required gem by following these steps:

          1. Open a terminal or command prompt.
          2. Run the following command:
             gem install at_coder_friends-generator-#{snake_gen_name}
          3. Once the above command completes, please run the program again.
        MSG
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
