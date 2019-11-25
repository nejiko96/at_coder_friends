# frozen_string_literal: true

module AtCoderFriends
  module Generator
    # generates C++ constants
    module CxxBuiltinConstGen
      def gen_const(c)
        v = cnv_const_value(c.value)
        if c.type == :max
          "const int #{c.name.upcase}_MAX = #{v};"
        else
          "const int MOD = #{v};"
        end
      end

      def cnv_const_value(v)
        v
          .sub(/\b10\^/, '1e')
          .sub(/\b2\^/, '1<<')
          .gsub(',', "'")
      end
    end

    # generates C++ variable declarations
    module CxxBuiltinDeclGen
      def gen_decl(inpdef)
        if inpdef.components
          inpdef.components.map { |cmp| gen_decl(cmp) }
        else
          case inpdef.container
          when :single
            gen_single_decl(inpdef)
          when :harray
            gen_harray_decl(inpdef)
          when :varray
            gen_varray_decl(inpdef)
          when :matrix
            gen_matrix_decl(inpdef)
          end
        end
      end

      def gen_single_decl(inpdef)
        names = inpdef.names
        case inpdef.item
        when :number
          dcl = names.join(', ')
          "int #{dcl};"
        when :string
          names.map { |v| "char #{v}[#{v.upcase}_MAX + 1];" }
        end
      end

      def gen_harray_decl(inpdef)
        v = inpdef.names[0]
        sz = gen_arr_size(inpdef.size)[0]
        case inpdef.item
        when :number
          "int #{v}[#{sz}];"
        when :string
          "char #{v}[#{sz}][#{v.upcase}_MAX + 1];"
        when :char
          "char #{v}[#{sz} + 1];"
        end
      end

      def gen_varray_decl(inpdef)
        names = inpdef.names
        sz = gen_arr_size(inpdef.size)[0]
        case inpdef.item
        when :number
          names.map { |v| "int #{v}[#{sz}];" }
        when :string
          names.map { |v| "char #{v}[#{sz}][#{v.upcase}_MAX + 1];" }
        end
      end

      def gen_matrix_decl(inpdef)
        v = inpdef.names[0]
        sz1, sz2 = gen_arr_size(inpdef.size)
        case inpdef.item
        when :number
          "int #{v}[#{sz1}][#{sz2}];"
        when :string
          "char #{v}[#{sz1}][#{sz2}][#{v.upcase}_MAX + 1];"
        when :char
          "char #{v}[#{sz1}][#{sz2} + 1];"
        end
      end

      def gen_arr_size(szs)
        szs.map { |sz| sz.gsub(/([a-z][a-z0-9_]*)/i, '\1_MAX').upcase }
      end
    end

    # generates C++ input source
    module CxxBuiltinInputGen
      SCANF_FMTS = [
        'scanf("%<fmt>s", %<addr>s);',
        'REP(i, %<sz1>s) scanf("%<fmt>s", %<addr>s);',
        'REP(i, %<sz1>s) REP(j, %<sz2>s) scanf("%<fmt>s", %<addr>s);'
      ].freeze
      SCANF_FMTS_VM = [
        <<~TEXT,
          REP(i, %<sz1>s) {
            scanf("%<va_fmt>s", %<va_addr>s);
            scanf("%<mx_fmt>s", %<mx_addr>s);
          }
        TEXT
        <<~TEXT
          REP(i, %<sz1>s) {
            scanf("%<va_fmt>s", %<va_addr>s);
            REP(j, %<sz2>s[i]) scanf("%<mx_fmt>s", %<mx_addr>s);
          }
        TEXT
      ].freeze
      FMT_FMTS = { number: '%d', string: '%s', char: '%s' }.freeze
      ADDR_FMTS = {
        single: {
          number: '&%<v>s',
          string: '%<v>s'
        },
        harray: {
          number: '%<v>s + i',
          string: '%<v>s[i]',
          char: '%<v>s'
        },
        varray: {
          number: '%<v>s + i',
          string: '%<v>s[i]'
        },
        matrix: {
          number: '&%<v>s[i][j]',
          string: '%<v>s[i][j]',
          char: '%<v>s[i]'
        }
      }.freeze

      def gen_input(inpdef)
        if inpdef.container == :varray_matrix
          gen_varray_matrix_input(inpdef)
        else
          gen_plain_input(inpdef)
        end
      end

      def gen_plain_input(inpdef)
        fmt, addr = scanf_params(inpdef)
        return unless fmt && addr

        scanf = SCANF_FMTS[inpdef.size.size - (inpdef.item == :char ? 1 : 0)]
        sz1, sz2 = inpdef.size
        format(scanf, sz1: sz1, sz2: sz2, fmt: fmt, addr: addr)
      end

      def gen_varray_matrix_input(inpdef)
        vadef, mxdef = inpdef.components
        va_fmt, va_addr = scanf_params(vadef)
        mx_fmt, mx_addr = scanf_params(mxdef)
        return unless va_fmt && va_addr
        return unless mx_fmt && mx_addr

        scanf = SCANF_FMTS_VM[inpdef.item == :char ? 0 : 1]
        sz1 = inpdef.size[0]
        sz2 = inpdef.size[1].split('_')[0]
        format(
          scanf,
          sz1: sz1, sz2: sz2,
          va_fmt: va_fmt, va_addr: va_addr,
          mx_fmt: mx_fmt, mx_addr: mx_addr
        ).split("\n")
      end

      def scanf_params(inpdef)
        [scanf_fmt(inpdef), scanf_addr(inpdef)]
      end

      def scanf_fmt(inpdef)
        return unless FMT_FMTS[inpdef.item]

        FMT_FMTS[inpdef.item] * inpdef.names.size
      end

      def scanf_addr(inpdef)
        return unless ADDR_FMTS[inpdef.container]
        return unless ADDR_FMTS[inpdef.container][inpdef.item]

        addr_fmt = ADDR_FMTS[inpdef.container][inpdef.item]
        inpdef.names.map { |v| format(addr_fmt, v: v) }.join(', ')
      end
    end

    # generates C++ source from problem description
    class CxxBuiltin < Base
      include CxxBuiltinConstGen
      include CxxBuiltinDeclGen
      include CxxBuiltinInputGen

      ACF_HOME = File.realpath(File.join(__dir__, '..', '..', '..'))
      TMPL_DIR = File.join(ACF_HOME, 'templates')
      DEFAULT_TMPL = File.join(TMPL_DIR, 'cxx_builtin.cxx.erb')
      ATTRS = Attributes.new(:cxx, DEFAULT_TMPL)

      def attrs
        ATTRS
      end

      def render(src)
        src = embed_lines(src, '/*** CONSTS ***/', gen_consts)
        src = embed_lines(src, '/*** DCLS ***/', gen_decls)
        src = embed_lines(src, '/*** INPUTS ***/', gen_inputs)
        src
      end

      def gen_consts(constants = pbm.constants)
        constants.map { |c| gen_const(c) }
      end

      def gen_decls(inpdefs = pbm.formats)
        inpdefs.map { |inpdef| gen_decl(inpdef) }.flatten
      end

      def gen_inputs(inpdefs = pbm.formats)
        inpdefs.map { |inpdef| gen_input(inpdef) }.flatten
      end
    end
  end
end
