# frozen_string_literal: true

module AtCoderFriends
  class CxxGenerator
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
      case inpdef.type
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
      vars = inpdef.vars
      case inpdef.fmt
      when :number
        dcl = vars.join(', ')
        "int #{dcl};"
      when :string
        vars.map { |v| "char #{v}[#{v.upcase}_MAX + 1];" }
      end
    end

    def gen_harray_decl(inpdef)
      vars = inpdef.vars
      sz = inpdef.size
      sz = "#{sz.upcase}_MAX" if sz =~ /\D/
      case inpdef.fmt
      when :number
        "int #{vars}[#{sz}];"
      when :string
        "char #{vars}[#{sz}][#{vars.upcase}_MAX + 1];"
      when :char
        "char #{vars}[#{sz} + 1];"
      end
    end

    def gen_varray_decl(inpdef)
      vars = inpdef.vars
      sz = inpdef.size
      sz = "#{sz.upcase}_MAX" if sz =~ /\D/
      case inpdef.fmt
      when :number
        vars.map { |v| "int #{v}[#{sz}];" }
      when :string
        vars.map { |v| "char #{v}[#{sz}][#{v.upcase}_MAX + 1];" }
      end
    end

    def gen_matrix_decl(inpdef)
      vars = inpdef.vars
      sz1, sz2 = inpdef.size
      sz1 = "#{sz1.upcase}_MAX" if sz1 =~ /\D/
      sz2 = "#{sz2.upcase}_MAX" if sz2 =~ /\D/
      case inpdef.fmt
      when :number
        "int #{vars}[#{sz1}][#{sz2}];"
      when :string
        "char #{vars}[#{sz1}][#{sz2}][#{vars.upcase}_MAX + 1];"
      when :char
        "char #{vars}[#{sz1}][#{sz2} + 1];"
      end
    end

    def gen_reads(defs)
      defs.map { |inpdef| gen_read(inpdef) }.flatten
    end

    def gen_read(inpdef)
      case inpdef.type
      when :single
        gen_single_read(inpdef)
      when :harray
        gen_harray_read(inpdef)
      when :varray
        gen_varray_read(inpdef)
      when :matrix
        gen_matrix_read(inpdef)
      end
    end

    def gen_single_read(inpdef)
      vars = inpdef.vars
      fmt = gen_fmt(inpdef)
      addr = (
        case inpdef.fmt
        when :number
          vars.map { |v| "&#{v}" }.join(', ')
        when :string
          vars.join(', ')
        end
      )
      "scanf(\"#{fmt}\", #{addr});"
    end

    def gen_harray_read(inpdef)
      vars = inpdef.vars
      fmt = gen_fmt(inpdef)
      sz = inpdef.size
      addr = (
        case inpdef.fmt
        when :number
          "#{vars} + i"
        when :string
          "#{vars}[i]"
        when :char
          vars
        end
      )
      case inpdef.fmt
      when :number, :string
        "REP(i, #{sz}) scanf(\"#{fmt}\", #{addr});"
      when :char
        "scanf(\"#{fmt}\", #{addr});"
      end
    end

    def gen_varray_read(inpdef)
      vars = inpdef.vars
      fmt = gen_fmt(inpdef)
      sz = inpdef.size
      addr = (
        case inpdef.fmt
        when :number
          vars.map { |v| "#{v} + i" }.join(', ')
        when :string
          vars.map { |v| "#{v}[i]" }.join(', ')
        end
      )
      "REP(i, #{sz}) scanf(\"#{fmt}\", #{addr});"
    end

    def gen_matrix_read(inpdef)
      vars = inpdef.vars
      fmt = gen_fmt(inpdef)
      sz1, sz2 = inpdef.size
      addr = (
        case inpdef.fmt
        when :number
          "&#{vars}[i][j]"
        when :string
          "#{vars}[i][j]"
        when :char
          "#{vars}[i]"
        end
      )
      case inpdef.fmt
      when :number, :string
        "REP(i, #{sz1}) REP(j, #{sz2}) scanf(\"#{fmt}\", #{addr});"
      when :char
        "REP(i, #{sz1}) scanf(\"#{fmt}\", #{addr});"
      end
    end

    def gen_fmt(inpdef)
      fmt = (
        case inpdef.fmt
        when :number
          '%d'
        when :string, :char
          '%s'
        end
      )
      vars = inpdef.vars
      fmt *= vars.size if vars.instance_of?(Array)
      fmt
    end
  end
end
