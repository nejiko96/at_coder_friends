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
      TYPE_TBL = {
        number: 'int',
        decimal: 'double',
        string: 'char',
        char: 'char'
      }.tap { |h| h.default = 'int' }
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
          when :matrix, :vmatrix, :hmatrix
            gen_matrix_decl(inpdef)
          end
        end
      end

      def gen_single_decl(inpdef)
        names, cols = inpdef.vars.transpose
        if cols.uniq.size == 1 && cols[0] != :string
          type = TYPE_TBL[cols[0]]
          dcl = names.join(', ')
          "#{type} #{dcl};"
        else
          inpdef.vars.map do |v, item|
            type = TYPE_TBL[item]
            dcl = v
            dcl += "[#{v.upcase}_MAX + 1]" if item == :string
            "#{type} #{dcl};"
          end
        end
      end

      def gen_harray_decl(inpdef)
        type = TYPE_TBL[inpdef.item]
        v = inpdef.names[0]
        sz = gen_arr_size(inpdef.size)[0]
        case inpdef.item
        when :number, :decimal
          "#{type} #{v}[#{sz}];"
        when :string
          "#{type} #{v}[#{sz}][#{v.upcase}_MAX + 1];"
        when :char
          "#{type} #{v}[#{sz} + 1];"
        end
      end

      def gen_varray_decl(inpdef)
        sz = gen_arr_size(inpdef.size)[0]
        inpdef.vars.map do |v, item|
          type = TYPE_TBL[item]
          dcl = "#{v}[#{sz}]"
          dcl += "[#{v.upcase}_MAX + 1]" if item == :string
          "#{type} #{dcl};"
        end
      end

      def gen_matrix_decl(inpdef)
        sz1, sz2 = gen_arr_size(inpdef.size)
        inpdef.vars.map do |v, item|
          type = TYPE_TBL[item]
          dcl = "#{v}[#{sz1}]"
          dcl += item == :char ? "[#{sz2} + 1]" : "[#{sz2}]"
          dcl += "[#{v.upcase}_MAX + 1]" if item == :string
          "#{type} #{dcl};"
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
      SCANF_FMTS_CMB = {
        varray_matrix:
          [
            <<~TEXT,
              REP(i, %<sz1>s) {
                scanf("%<fmt1>s", %<addr1>s);
                scanf("%<fmt2>s", %<addr2>s);
              }
            TEXT
            <<~TEXT
              REP(i, %<sz1>s) {
                scanf("%<fmt1>s", %<addr1>s);
                REP(j, %<sz2>s[i]) scanf("%<fmt2>s", %<addr2>s);
              }
            TEXT
          ],
        matrix_varray:
          [
            <<~TEXT,
              REP(i, %<sz1>s) {
                scanf("%<fmt1>s", %<addr1>s);
                scanf("%<fmt2>s", %<addr2>s);
              }
            TEXT
            <<~TEXT
              REP(i, %<sz1>s) {
                REP(j, %<sz2>s) scanf("%<fmt1>s", %<addr1>s);
                scanf("%<fmt2>s", %<addr2>s);
              }
            TEXT
          ]
      }.tap { |h| h.default = h[:varray_matrix] }
      FMT_FMTS = {
        number: '%d',
        decimal: '%lf',
        string: '%s',
        char: '%s'
      }.tap { |h| h.default = h[:number] }
      SINGLE_ADDR_FMTS = {
        number: '&%<v>s',
        decimal: '&%<v>s',
        string: '%<v>s'
      }.tap { |h| h.default = h[:number] }
      ARRAY_ADDR_FMTS = {
        number: '%<v>s + i',
        decimal: '%<v>s + i',
        string: '%<v>s[i]',
        char: '%<v>s'
      }.tap { |h| h.default = h[:number] }
      MATRIX_ADDR_FMTS = {
        number: '&%<v>s[i][j]',
        decimal: '&%<v>s[i][j]',
        string: '%<v>s[i][j]',
        char: '%<v>s[i]'
      }.tap { |h| h.default = h[:number] }
      ADDR_FMTS = {
        single: SINGLE_ADDR_FMTS,
        harray: ARRAY_ADDR_FMTS,
        varray: ARRAY_ADDR_FMTS,
        matrix: MATRIX_ADDR_FMTS,
        vmatrix: MATRIX_ADDR_FMTS,
        hmatrix: MATRIX_ADDR_FMTS
      }.tap { |h| h.default = h[:single] }

      def gen_input(inpdef)
        if inpdef.components
          gen_cmb_input(inpdef)
        else
          gen_plain_input(inpdef)
        end
      end

      def gen_plain_input(inpdef)
        scanf = SCANF_FMTS[inpdef.size.size - (inpdef.item == :char ? 1 : 0)]
        sz1, sz2 = inpdef.size
        fmt, addr = scanf_params(inpdef)
        format(scanf, sz1: sz1, sz2: sz2, fmt: fmt, addr: addr)
      end

      def gen_cmb_input(inpdef)
        scanf = SCANF_FMTS_CMB.dig(
          inpdef.container, inpdef.item == :char ? 0 : 1
        )
        sz1 = inpdef.size[0]
        sz2 = inpdef.size[1].split('_')[0]
        fmt1, addr1, fmt2, addr2 =
          inpdef.components.map { |cmp| scanf_params(cmp) }.flatten
        format(
          scanf,
          sz1: sz1, sz2: sz2,
          fmt1: fmt1, addr1: addr1,
          fmt2: fmt2, addr2: addr2
        ).split("\n")
      end

      def scanf_params(inpdef)
        [scanf_fmt(inpdef), scanf_addr(inpdef)]
      end

      def scanf_fmt(inpdef)
        inpdef.vars.map { |(_v, item)| FMT_FMTS[item] }.join
      end

      def scanf_addr(inpdef)
        inpdef.vars.map do |(v, item)|
          addr_fmt = ADDR_FMTS.dig(inpdef.container, item)
          format(addr_fmt, v: v)
        end.join(', ')
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
        embed_lines(src, '/*** INPUTS ***/', gen_inputs)
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
