# frozen_string_literal: true

module AtCoderFriends
  class RubyGenerator
    TEMPLATE = <<~TEXT
      ### DCLS ###

      puts ans
    TEXT

    def generate(pbm)
      dcls = gen_decls(pbm.defs)
      src = TEMPLATE
            .sub('### DCLS ###', dcls.join("\n"))
      pbm.add_src(:rb, src)
    end

    def gen_decls(inpdefs)
      dcls = []
      inpdefs.each do |inpdef|
        vars = inpdef.vars
        case inpdef.type
        when :single
          dcl = vars.join(', ')
          case inpdef.fmt
          when :number
            if vars.size == 1
              dcls << "#{dcl} = gets.to_i"
            else
              dcls << "#{dcl} = gets.split.map(&:to_i)"
            end
          when :string
            if vars.size == 1
              dcls << "#{dcl} = gets.chomp"
            else
              dcls << "#{dcl} = gets.chomp.split"
            end
          end
        when :harray
          dcl = "#{vars}s"
          case inpdef.fmt
          when :number
            dcls << "#{dcl} = gets.split.map(&:to_i)"
          when :string
            dcls << "#{dcl} = gets.chomp.split"
          when :char
            dcls << "#{dcl} = gets.chomp"
          end
        when :varray
          sz = inpdef.size
          if vars.size == 1
            dcl = "#{vars[0]}s"
            case inpdef.fmt
            when :number
              dcls << "#{dcl} = Array.new(#{sz}) { gets.to_i }"
            when :string
              dcls << "#{dcl} = Array.new(#{sz}) { gets.chomp }"
            end
          else
            vars.each do |v|
              dcls << "#{v}s = Array.new(#{sz})"
            end
            dcl = vars.map { |v| "#{v}s[i]" }.join(', ')
            dcls << "#{sz}.times do |i|"
            case inpdef.fmt
            when :number
              if vars.size == 1
                dcls << "  #{dcl} = gets.to_i"
              else
                dcls << "  #{dcl} = gets.split.map(&:to_i)"
              end
            when :string
              if vars.size == 1
                dcls << "  #{dcl} = gets.chomp"
              else
                dcls << "  #{dcl} = gets.chomp.split"
              end
            end
            dcls << 'end'
          end
        when :matrix
          sz = inpdef.size[0]
          case inpdef.fmt
          when :number
            expr = 'gets.split.map(&:to_i)'
          when :string
            expr = 'gets.chomp.split'
          when :char
            expr = 'gets.chomp'
          end
          dcls << "#{vars}ss = Array.new(#{sz}) { #{expr} }"
        end
      end
      dcls
    end
  end
end
