# frozen_string_literal: true

module AtCoderFriends
  class RubyGenerator
    TEMPLATE = <<~TEXT
      ### DCLS ###

      puts ans
    TEXT

    def process(pbm)
      src = generate(pbm.defs)
      pbm.add_src(:rb, src)
    end

    def generate(defs)
      dcls = gen_decls(defs).join("\n")
      TEMPLATE.sub('### DCLS ###', dcls)
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
        if inpdef.vars.size == 1
          gen_varray_1_decl(inpdef)
        else
          gen_varray_n_decl(inpdef)
        end
      when :matrix
        gen_matrix_decl(inpdef)
      end
    end

    def gen_single_decl(inpdef)
      vars = inpdef.vars
      dcl = vars.join(', ')
      expr = gen_expr(inpdef.fmt, vars.size > 1)
      "#{dcl} = #{expr}"
    end

    def gen_harray_decl(inpdef)
      vars = inpdef.vars
      dcl = "#{vars}s"
      expr = gen_expr(inpdef.fmt, true)
      "#{dcl} = #{expr}"
    end

    def gen_varray_1_decl(inpdef)
      vars = inpdef.vars
      sz = inpdef.size
      dcl = "#{vars[0]}s"
      expr = gen_expr(inpdef.fmt, false)
      "#{dcl} = Array.new(#{sz}) { #{expr} }"
    end

    def gen_varray_n_decl(inpdef)
      vars = inpdef.vars
      sz = inpdef.size
      dcl = vars.map { |v| "#{v}s[i]" }.join(', ')
      expr = gen_expr(inpdef.fmt, true)
      ret = []
      vars.each do |v|
        ret << "#{v}s = Array.new(#{sz})"
      end
      ret << "#{sz}.times do |i|"
      ret << "  #{dcl} = #{expr}"
      ret << 'end'
      ret
    end

    def gen_matrix_decl(inpdef)
      vars = inpdef.vars
      sz = inpdef.size[0]
      decl = "#{vars}ss"
      expr = gen_expr(inpdef.fmt, true)
      "#{decl} = Array.new(#{sz}) { #{expr} }"
    end

    def gen_expr(fmt, split)
      case fmt
      when :number
        split ? 'gets.split.map(&:to_i)' : 'gets.to_i'
      when :string
        split ? 'gets.chomp.split' : 'gets.chomp'
      when :char
        'gets.chomp'
      end
    end
  end
end
