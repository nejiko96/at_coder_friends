# frozen_string_literal: true

module AtCoderFriends
  module Generator
    module CxxBuiltinConstants
      TEMPLATE = <<~TEXT
        // /*** URL ***/

        #include <cstdio>

        using namespace std;

        #define REP(i,n)   for(int i=0; i<(int)(n); i++)
        #define FOR(i,b,e) for(int i=(b); i<=(int)(e); i++)

        /*** CONSTS ***/

        /*** DCLS ***/

        void solve() {
          int ans = 0;
          printf("%d\\n", ans);
        }

        void input() {
        /*** READS ***/
        }

        int main() {
          input();
          solve();
          return 0;
        }
      TEXT

      SCANF_FMTS = [
        'scanf("%<fmt>s", %<addr>s);',
        'REP(i, %<sz1>s) scanf("%<fmt>s", %<addr>s);',
        'REP(i, %<sz1>s) REP(j, %<sz2>s) scanf("%<fmt>s", %<addr>s);'
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
    end

    # generates C++ source code from definition
    class CxxBuiltin
      include CxxBuiltinConstants

      def initialize(cfg = {})
        @cfg = cfg
      end

      def process(pbm)
        src = generate(pbm.url, pbm.formats, pbm.constraints)
        pbm.add_src(:cxx, src)
      end

      def generate(url, defs, constraints)
        consts = gen_consts(constraints)
        dcls = gen_decls(defs)
        reads = gen_reads(defs)
        TEMPLATE
          .sub('/*** URL ***/', url)
          .sub('/*** CONSTS ***/', consts.join("\n"))
          .sub('/*** DCLS ***/', dcls.join("\n"))
          .sub('/*** READS ***/', reads.map { |s| '  ' + s }.join("\n"))
      end

      def gen_consts(constraints)
        constraints
          .select { |c| c.type == :max }
          .map { |c| "const int #{c.name.upcase}_MAX = #{c.value};" }
      end

      def gen_decls(defs)
        defs.map { |inpdef| gen_decl(inpdef) }.flatten
      end

      def gen_decl(inpdef)
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
        szs.map { |sz| sz =~ /\D/ ? "#{sz.upcase}_MAX" : sz }
      end

      def gen_reads(defs)
        defs.map { |inpdef| gen_read(inpdef) }.flatten
      end

      # rubocop:disable Metrics/AbcSize
      def gen_read(inpdef)
        dim = inpdef.size.size - (inpdef.item == :char ? 1 : 0)
        scanf = SCANF_FMTS[dim]
        sz1, sz2 = inpdef.size
        fmt = FMT_FMTS[inpdef.item] * inpdef.names.size
        addr_fmt = ADDR_FMTS[inpdef.container][inpdef.item]
        addr = inpdef.names.map { |v| format(addr_fmt, v: v) }.join(', ')
        format(scanf, sz1: sz1, sz2: sz2, fmt: fmt, addr: addr)
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
