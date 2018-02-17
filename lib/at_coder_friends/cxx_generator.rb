# frozen_string_literal: true

module AtCoderFriends
  # generates C++ source code from definition
  class CxxGenerator
    # rubocop:disable Style/FormatStringToken
    TEMPLATE = <<~TEXT
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
    # rubocop:enable Style/FormatStringToken

    SCANF_FMTS = [
      'scanf("%<fmt>s", %<addr>s);',
      'REP(i, %<sz1>s) scanf("%<fmt>s", %<addr>s);',
      'REP(i, %<sz1>s) REP(j, %<sz2>s) scanf("%<fmt>s", %<addr>s);'
    ].freeze

    # rubocop:disable Style/FormatStringToken
    FMT_FMTS = { number: '%d', string: '%s', char: '%s' }.freeze
    # rubocop:enable Style/FormatStringToken

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

    def process(pbm)
      src = generate(pbm.defs, pbm.desc)
      pbm.add_src(:cxx, src)
    end

    def generate(defs, desc)
      consts = gen_consts(desc)
      dcls = gen_decls(defs)
      reads = gen_reads(defs)
      TEMPLATE
        .sub('/*** CONSTS ***/', consts.join("\n"))
        .sub('/*** DCLS ***/', dcls.join("\n"))
        .sub('/*** READS ***/', reads.map { |s| '  ' + s }.join("\n"))
    end

    def gen_consts(desc)
      desc
        .gsub(/[,\\\(\)\{\}\|]/, '')
        .gsub(/(≤|leq)/i, '≦')
        .scan(/([\da-z_]+)\s*≦\s*(\d+)(?:\^(\d+))?/i)
        .map do |v, sz, k|
          sz = sz.to_i
          sz **= k.to_i if k
          "const int #{v.upcase}_MAX = #{sz};"
        end
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
      names = inpdef.names
      sz = gen_max_size(inpdef.size)
      case inpdef.item
      when :number
        "int #{names}[#{sz}];"
      when :string
        "char #{names}[#{sz}][#{names.upcase}_MAX + 1];"
      when :char
        "char #{names}[#{sz} + 1];"
      end
    end

    def gen_varray_decl(inpdef)
      names = inpdef.names
      sz = gen_max_size(inpdef.size)
      case inpdef.item
      when :number
        names.map { |v| "int #{v}[#{sz}];" }
      when :string
        names.map { |v| "char #{v}[#{sz}][#{v.upcase}_MAX + 1];" }
      end
    end

    def gen_matrix_decl(inpdef)
      names = inpdef.names
      sz1, sz2 = inpdef.size.map { |sz| gen_max_size(sz) }
      case inpdef.item
      when :number
        "int #{names}[#{sz1}][#{sz2}];"
      when :string
        "char #{names}[#{sz1}][#{sz2}][#{names.upcase}_MAX + 1];"
      when :char
        "char #{names}[#{sz1}][#{sz2} + 1];"
      end
    end

    def gen_max_size(sz)
      sz =~ /\D/ ? "#{sz.upcase}_MAX" : sz
    end

    def gen_reads(defs)
      defs.map { |inpdef| gen_read(inpdef) }.flatten
    end

    def gen_read(inpdef)
      sz1, sz2 = inpdef.size
      fmt = gen_fmt(inpdef)
      addr = gen_addr(inpdef)
      scanf = scanf_fmt(inpdef)
      format(scanf, sz1: sz1, sz2: sz2, fmt: fmt, addr: addr)
    end

    def gen_fmt(inpdef)
      names = inpdef.names
      item = FMT_FMTS[inpdef.item]
      item *= names.size if names.instance_of?(Array)
      item
    end

    def gen_addr(inpdef)
      addr_fmt = ADDR_FMTS[inpdef.container][inpdef.item]
      if inpdef.names.instance_of?(Array)
        inpdef.names.map { |v| format(addr_fmt, v: v) }.join(', ')
      else
        format(addr_fmt, v: inpdef.names)
      end
    end

    def scanf_fmt(inpdef)
      ix = inpdef.size ? inpdef.size.instance_of?(Array) ? 2 : 1 : 0
      ix -= 1 if inpdef.item == :char
      SCANF_FMTS[ix]
    end
  end
end
