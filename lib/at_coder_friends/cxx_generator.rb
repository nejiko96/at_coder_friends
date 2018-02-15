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
      consts = []
      desc = desc.gsub(/[,\\\(\)\{\}\|]/, '')
      desc.scan(/([\da-z_]+)\s*(≤|≦|leq)\s*(\d+)(\^(\d+))?/i) do |v, _, sz, _, k|
        sz = sz.to_i
        sz **= k.to_i if k
        consts << "const int #{v.upcase}_MAX = #{sz};"
      end
      consts
    end

    def gen_decls(inpdefs)
      dcls = []
      inpdefs.each do |inpdef|
        vars = inpdef.vars
        case inpdef.type
        when :single
          case inpdef.fmt
          when :number
            dcl = vars.join(', ')
            dcls << "int #{dcl};"
          when :string
            vars.each do |v|
              dcls << "char #{v}[#{v.upcase}_MAX + 1];"
            end
          end
        when :harray
          sz = inpdef.size
          sz = "#{sz.upcase}_MAX" if sz =~ /\D/
          case inpdef.fmt
          when :number
            dcls << "int #{vars}[#{sz}];"
          when :string
            dcls << "char #{vars}[#{sz}][#{vars.upcase}_MAX + 1];"
          when :char
            dcls << "char #{vars}[#{sz} + 1];"
          end
        when :varray
          sz = inpdef.size
          sz = "#{sz.upcase}_MAX" if sz =~ /\D/
          vars.each do |v|
            case inpdef.fmt
            when :number
              dcls << "int #{v}[#{sz}];"
            when :string
              dcls << "char #{v}[#{sz}][#{v.upcase}_MAX + 1];"
            end
          end
        when :matrix
          sz1, sz2 = inpdef.size
          sz1 = "#{sz1.upcase}_MAX" if sz1 =~ /\D/
          sz2 = "#{sz2.upcase}_MAX" if sz2 =~ /\D/
          case inpdef.fmt
          when :number
            dcls << "int #{vars}[#{sz1}][#{sz2}];"
          when :string
            dcls << "char #{vars}[#{sz1}][#{sz2}][#{vars.upcase}_MAX + 1];"
          when :char
            dcls << "char #{vars}[#{sz1}][#{sz2} + 1];"
          end
        end
      end
      dcls
    end

    def gen_reads(inpdefs)
      reads = []
      inpdefs.each do |inpdef|
        vars = inpdef.vars
        case inpdef.fmt
        when :number
          fmt = '%d'
        when :string, :char
          fmt = '%s'
        end
        case inpdef.type
        when :single
          fmt *= vars.size
          case inpdef.fmt
          when :number
            dcl = vars.map { |v| "&#{v}" }.join(', ')
          when :string
            dcl = vars.join(', ')
          end
          reads << "scanf(\"#{fmt}\", #{dcl});"
        when :harray
          sz = inpdef.size
          case inpdef.fmt
          when :number
            dcl = "#{vars} + i"
          when :string
            dcl = "#{vars}[i]"
          when :char
            dcl = vars
          end
          case inpdef.fmt
          when :number, :string
            reads << "REP(i, #{sz}) scanf(\"#{fmt}\", #{dcl});"
          when :char
            reads << "scanf(\"#{fmt}\", #{dcl});"
          end
        when :varray
          sz = inpdef.size
          fmt *= vars.size
          case inpdef.fmt
          when :number
            dcl = vars.map { |v| "#{v} + i" }.join(', ')
          when :string
            dcl = vars.map { |v| "#{v}[i]" }.join(', ')
          end
          reads << "REP(i, #{sz}) scanf(\"#{fmt}\", #{dcl});"
        when :matrix
          sz1, sz2 = inpdef.size
          case inpdef.fmt
          when :number
            dcl = "&#{vars}[i][j]"
          when :string
            dcl = "#{vars}[i][j]"
          when :char
            dcl = "#{vars}[i]"
          end
          case inpdef.fmt
          when :number, :string
            reads << "REP(i, #{sz1}) REP(j, #{sz2}) scanf(\"#{fmt}\", #{dcl});"
          when :char
            reads << "REP(i, #{sz1}) scanf(\"#{fmt}\", #{dcl});"
          end
        end
      end
      reads
    end
  end
end
