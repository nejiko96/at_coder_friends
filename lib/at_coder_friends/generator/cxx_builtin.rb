# frozen_string_literal: true

module AtCoderFriends
  module Generator
    # generates C++ source from problem description
    class CxxBuiltin < CBuiltin
      DEFAULT_TMPL = File.join(TMPL_DIR, 'cxx_builtin.cxx.erb')
      ATTRS = Attributes.new(:cxx, DEFAULT_TMPL, FRAGMENTS)

      def attrs
        ATTRS
      end

      def gen_const(c)
        ConstFragment.new(c, fragments['cxx_constant']).generate
      end

      # deprecated, use ERB syntax
      def render(src)
        src = embed_lines(src, '/*** CONSTS ***/', gen_consts)
        src = embed_lines(src, '/*** DCLS ***/', gen_decls)
        embed_lines(src, '/*** INPUTS ***/', gen_inputs)
      end
    end
  end
end
