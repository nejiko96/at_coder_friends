# frozen_string_literal: true

module AtCoderFriends
  module Generator
    # C variable declaration generator
    class CBuiltinDeclFragment < InputFormatFragment
      def generate
        main
      end

      def main
        render('main', vertical_type)
      end

      def line
        render('line', horizontal_type)
      end

      def type
        render('type', item.to_s)
      end

      def vertical_type
        return 'combi' if components

        case container
        when :single
          items = vars.map(&:item)
          if items.uniq.size == 1 && items[0] != :string
            'single'
          else
            'multi'
          end
        when :harray
          'single'
        else # :varray. :matrix, :vmatrix, :hmatrix
          'multi'
        end
      end

      def horizontal_type
        case container
        when :single
          items = vars.map(&:item)
          if items.uniq.size == 1 && items[0] != :string
            'multi'
          else
            'single'
          end
        when :harray, :varray
          'array'
        else # :matrix, :vmatrix, :hmatrix
          'matrix'
        end
      end
    end

    # C variable input code generator
    class CBuiltinInputFragment < InputFormatFragment
      def generate
        main
      end

      def main
        render('main', input_type, dim_type)
      end

      def item_format
        render('item_format', item.to_s)
      end

      def item_address
        render('item_address', address_type, item.to_s)
      end
    end

    # generates C source from problem description
    class CBuiltin < Base
      ACF_HOME = File.realpath(File.join(__dir__, '..', '..', '..'))
      TMPL_DIR = File.join(ACF_HOME, 'templates')
      DEFAULT_TMPL = File.join(TMPL_DIR, 'c_builtin.c.erb')
      FRAGMENTS = File.join(TMPL_DIR, 'c_builtin_fragments.yml')
      ATTRS = Attributes.new(:c, DEFAULT_TMPL, FRAGMENTS)

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
        CBuiltinDeclFragment.new(inpdef, fragments['declaration']).generate
      end

      def gen_inputs(inpdefs = pbm.formats)
        inpdefs.map { |inpdef| gen_input(inpdef) }.flatten
      end

      def gen_input(inpdef)
        CBuiltinInputFragment.new(inpdef, fragments['input']).generate
      end
    end
  end
end
