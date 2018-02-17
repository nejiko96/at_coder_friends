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
      sz = inpdef.size
      sz = "#{sz.upcase}_MAX" if sz =~ /\D/
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
      sz = inpdef.size
      sz = "#{sz.upcase}_MAX" if sz =~ /\D/
      case inpdef.item
      when :number
        names.map { |v| "int #{v}[#{sz}];" }
      when :string
        names.map { |v| "char #{v}[#{sz}][#{v.upcase}_MAX + 1];" }
      end
    end

    def gen_matrix_decl(inpdef)
      names = inpdef.names
      sz1, sz2 = inpdef.size
      sz1 = "#{sz1.upcase}_MAX" if sz1 =~ /\D/
      sz2 = "#{sz2.upcase}_MAX" if sz2 =~ /\D/
      case inpdef.item
      when :number
        "int #{names}[#{sz1}][#{sz2}];"
      when :string
        "char #{names}[#{sz1}][#{sz2}][#{names.upcase}_MAX + 1];"
      when :char
        "char #{names}[#{sz1}][#{sz2} + 1];"
      end
    end

    def gen_reads(defs)
      defs.map { |inpdef| gen_read(inpdef) }.flatten
    end

    def gen_read(inpdef)
      case inpdef.container
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
      names = inpdef.names
      fmt = gen_fmt(inpdef)
      addr = (
        case inpdef.item
        when :number
          names.map { |v| "&#{v}" }.join(', ')
        when :string
          names.join(', ')
        end
      )
      "scanf(\"#{fmt}\", #{addr});"
    end

    def gen_harray_read(inpdef)
      names = inpdef.names
      fmt = gen_fmt(inpdef)
      sz = inpdef.size
      addr = (
        case inpdef.item
        when :number
          "#{names} + i"
        when :string
          "#{names}[i]"
        when :char
          names
        end
      )
      case inpdef.item
      when :number, :string
        "REP(i, #{sz}) scanf(\"#{fmt}\", #{addr});"
      when :char
        "scanf(\"#{fmt}\", #{addr});"
      end
    end

    def gen_varray_read(inpdef)
      names = inpdef.names
      fmt = gen_fmt(inpdef)
      sz = inpdef.size
      addr = (
        case inpdef.item
        when :number
          names.map { |v| "#{v} + i" }.join(', ')
        when :string
          names.map { |v| "#{v}[i]" }.join(', ')
        end
      )
      "REP(i, #{sz}) scanf(\"#{fmt}\", #{addr});"
    end

    def gen_matrix_read(inpdef)
      names = inpdef.names
      fmt = gen_fmt(inpdef)
      sz1, sz2 = inpdef.size
      addr = (
        case inpdef.item
        when :number
          "&#{names}[i][j]"
        when :string
          "#{names}[i][j]"
        when :char
          "#{names}[i]"
        end
      )
      case inpdef.item
      when :number, :string
        "REP(i, #{sz1}) REP(j, #{sz2}) scanf(\"#{fmt}\", #{addr});"
      when :char
        "REP(i, #{sz1}) scanf(\"#{fmt}\", #{addr});"
      end
    end

    def gen_fmt(inpdef)
      item = (
        case inpdef.item
        when :number
          '%d'
        when :string, :char
          '%s'
        end
      )
      names = inpdef.names
      item *= names.size if names.instance_of?(Array)
      item
    end
  end
end
