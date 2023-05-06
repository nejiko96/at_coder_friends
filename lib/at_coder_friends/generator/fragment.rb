# frozen_string_literal: true

require 'erb'

module AtCoderFriends
  module Generator
    # base class for code fragment generator
    class FragmentBase
      attr_reader :templates

      def initialize(obj, templates)
        @obj = obj
        @templates = templates
      end

      def render(*keys)
        keys = keys.map(&:to_s)
        template = templates.dig(*keys) || (raise AppError, "fragment key #{keys} not found")

        return ERB.new(template, trim_mode: '-').result(binding) if template.is_a?(String)

        if template.is_a?(Hash)
          sub_key_props = template['__key'] || (raise AppError, "'__key' not found in fragment hash #{keys}")
          sub_keys = sub_key_props.map { |k| send(k) }
          return render(*keys, *sub_keys)
        end

        raise AppError, "can't render fragment #{keys}"
      end

      # delegate method calls to obj
      def method_missing(name, *args, &block)
        if @obj.respond_to?(name)
          @obj.send(name, *args, &block)
        elsif templates.key?(name.to_s)
          render(name)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        @obj.respond_to?(name, include_private) ||
          templates.key?(name.to_s) ||
          super
      end

      def to_s
        @obj.to_s
      end
    end

    # base class for constant declaration generator
    class ConstFragment < FragmentBase
      def generate
        render(type)
      end
    end

    # base class for variable declaration generator
    class InputFormatFragment < FragmentBase
      def generate
        render(:main)
      end

      def vs
        names
      end

      def v
        vs[0]
      end

      def sz1
        size[0]
      end
      alias sz sz1

      def sz2
        size[1]
      end

      def delims
        delim.chars
      end

      def vars
        @vars ||= super.map do |v, item|
          var = Problem::InputFormat.new(
            container: container,
            names: [v],
            item: item,
            size: size
          )
          self.class.new(var, templates)
        end
      end

      def components
        @components ||= super&.map do |cmp|
          self.class.new(cmp, templates)
        end
      end
    end
  end
end
