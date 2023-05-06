# frozen_string_literal: true

module AtCoderFriends
  module Generator
    # generates C source from problem description
    class CBuiltin < Base
      include CommonFragmentMixin
      ACF_HOME = File.realpath(File.join(__dir__, '..', '..', '..'))
      TMPL_DIR = File.join(ACF_HOME, 'templates')
      TEMPLATE = File.join(TMPL_DIR, 'c_builtin.c.erb')
      FRAGMENTS = File.join(TMPL_DIR, 'c_builtin_fragments.yml')
      ATTRS = Attributes.new(:c, TEMPLATE, FRAGMENTS)

      def attrs
        ATTRS
      end

      def gen_inputs
        inpdefs.map { |inpdef| gen_input(inpdef).split("\n") }.flatten
      end

      def gen_input(inpdef)
        InputFormatFragment.new(inpdef, fragments['input']).generate
      end
    end
  end
end
