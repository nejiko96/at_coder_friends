# frozen_string_literal: true

module AtCoderFriends
  module Generator
    # variable declaration generator
    class AnyBuiltinDeclFragment < InputFormatFragment
      def generate
        main
      end
    end

    # generates source from template
    class AnyBuiltin < Base
      ACF_HOME = File.realpath(File.join(__dir__, '..', '..', '..'))
      TMPL_DIR = File.join(ACF_HOME, 'templates')
      TEMPLATE = File.join(TMPL_DIR, 'any_builtin.md.erb')
      FRAGMENTS = File.join(TMPL_DIR, 'any_builtin_fragments.yml')
      ATTRS = Attributes.new(:md, TEMPLATE, FRAGMENTS)

      def attrs
        ATTRS
      end

      def gen_consts(constants = pbm.constants)
        constants.map { |c| gen_const(c) }
      end

      def gen_const(c)
        ConstFragment.new(c, fragments['constant']).generate
      end

      def gen_decls(inpdefs = pbm.formats)
        inpdefs.map { |inpdef| gen_decl(inpdef).split("\n") }.flatten
      end

      def gen_decl(inpdef)
        AnyBuiltinDeclFragment.new(inpdef, fragments['declaration']).generate
      end
    end
  end
end
