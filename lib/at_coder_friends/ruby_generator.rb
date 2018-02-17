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
      case inpdef.container
      when :single
        gen_single_decl(inpdef)
      when :harray
        gen_harray_decl(inpdef)
      when :varray
        if inpdef.names.size == 1
          gen_varray_1_decl(inpdef)
        else
          gen_varray_n_decl(inpdef)
        end
      when :matrix
        gen_matrix_decl(inpdef)
      end
    end

    def gen_single_decl(inpdef)
      names = inpdef.names
      dcl = names.join(', ')
      expr = gen_expr(inpdef.item, names.size > 1)
      "#{dcl} = #{expr}"
    end

    def gen_harray_decl(inpdef)
      names = inpdef.names
      dcl = "#{names}s"
      expr = gen_expr(inpdef.item, true)
      "#{dcl} = #{expr}"
    end

    def gen_varray_1_decl(inpdef)
      names = inpdef.names
      sz = inpdef.size
      dcl = "#{names[0]}s"
      expr = gen_expr(inpdef.item, false)
      "#{dcl} = Array.new(#{sz}) { #{expr} }"
    end

    def gen_varray_n_decl(inpdef)
      names = inpdef.names
      sz = inpdef.size
      dcl = names.map { |v| "#{v}s[i]" }.join(', ')
      expr = gen_expr(inpdef.item, true)
      ret = []
      names.each do |v|
        ret << "#{v}s = Array.new(#{sz})"
      end
      ret << "#{sz}.times do |i|"
      ret << "  #{dcl} = #{expr}"
      ret << 'end'
      ret
    end

    def gen_matrix_decl(inpdef)
      names = inpdef.names
      sz = inpdef.size[0]
      decl = "#{names}ss"
      expr = gen_expr(inpdef.item, true)
      "#{decl} = Array.new(#{sz}) { #{expr} }"
    end

    def gen_expr(item, split)
      case item
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
