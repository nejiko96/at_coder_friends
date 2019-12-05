# frozen_string_literal: true

module AtCoderFriends
  module Generator
    # generates Ruby source from problem description
    class RubyBuiltin < Base
      ACF_HOME = File.realpath(File.join(__dir__, '..', '..', '..'))
      TMPL_DIR = File.join(ACF_HOME, 'templates')
      DEFAULT_TMPL = File.join(TMPL_DIR, 'ruby_builtin.rb.erb')
      ATTRS = Attributes.new(:rb, DEFAULT_TMPL)

      def attrs
        ATTRS
      end

      def render(src)
        src = embed_lines(src, '### CONSTS ###', gen_consts)
        src = embed_lines(src, '### DCLS ###', gen_decls)
        src
      end

      def gen_consts(constants = pbm.constants)
        constants
          .select { |c| c.type == :mod }
          .map { |c| gen_mod(c) }
      end

      def gen_mod(c)
        v = c.value.gsub('^', '**').gsub(',', '_')
        "MOD = #{v}"
      end

      def gen_decls(inpdefs = pbm.formats)
        inpdefs.map { |inpdef| gen_decl(inpdef) }.flatten
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
        when :varray_matrix, :matrix_varray
          gen_cmb_decl(inpdef)
        when :vmatrix
          gen_vmatrix_decl(inpdef)
        when :hmatrix
          gen_hmatrix_decl(inpdef)
        end
      end

      def gen_single_decl(inpdef)
        names = inpdef.names
        dcl = names.join(', ')
        expr = gen_expr(inpdef.item, names.size > 1)
        "#{dcl} = #{expr}"
      end

      def gen_harray_decl(inpdef)
        v = inpdef.names[0]
        dcl = "#{v}s"
        expr = gen_expr(inpdef.item, true)
        "#{dcl} = #{expr}"
      end

      def gen_varray_decl(inpdef)
        if inpdef.names.size == 1
          gen_varray_1_decl(inpdef)
        else
          gen_varray_n_decl(inpdef)
        end
      end

      def gen_varray_1_decl(inpdef)
        v = inpdef.names[0]
        sz = inpdef.size[0]
        dcl = "#{v}s"
        expr = gen_expr(inpdef.item, false)
        "#{dcl} = Array.new(#{sz}) { #{expr} }"
      end

      def gen_varray_n_decl(inpdef)
        names = inpdef.names
        sz = inpdef.size[0]
        dcl = names.map { |v| "#{v}s[i]" }.join(', ')
        expr = gen_expr(inpdef.item, true)
        ret = []
        ret += names.map { |v| "#{v}s = Array.new(#{sz})" }
        ret << "#{sz}.times do |i|"
        ret << "  #{dcl} = #{expr}"
        ret << 'end'
        ret
      end

      def gen_matrix_decl(inpdef)
        v = inpdef.names[0]
        sz = inpdef.size[0]
        decl = "#{v}ss"
        expr = gen_expr(inpdef.item, true)
        "#{decl} = Array.new(#{sz}) { #{expr} }"
      end

      def gen_cmb_decl(inpdef)
        mx = inpdef.container == :varray_matrix ? -1 : 0
        vs = inpdef.names.map { |v| "#{v}s" }
        vs[mx] += 's'
        sz = inpdef.size[0]
        dcls = vs.map { |v| "#{v}[i]" }
        dcls[mx] = '*' + dcls[mx] unless inpdef.item == :char
        dcl = dcls.join(', ')
        expr = gen_cmb_expr(inpdef.item)
        ret = []
        ret += vs.map { |v| "#{v} = Array.new(#{sz})" }
        ret << "#{sz}.times do |i|"
        ret << "  #{dcl} = #{expr}"
        ret << 'end'
        ret
      end

      def gen_vmatrix_decl(inpdef)
        names = inpdef.names
        sz1, sz2 = inpdef.size
        dcl = names.map { |v| "#{v}ss[i][j]" }.join(', ')
        expr = gen_expr(inpdef.item, true)
        ret = []
        ret += names.map do |v|
          "#{v}ss = Array.new(#{sz1}) { Array.new(#{sz2}) }"
        end
        ret << "#{sz1}.times do |i|"
        ret << "  #{sz2}.times do |j|"
        ret << "    #{dcl} = #{expr}"
        ret << '  end'
        ret << 'end'
        ret
      end

      def gen_hmatrix_decl(inpdef)
        names = inpdef.names
        sz = inpdef.size[0]
        dcl = names.map { |v| "#{v}ss[i]" }.join(', ')
        expr = gen_expr(inpdef.item, true)
        ret = []
        ret += names.map { |v| "#{v}ss = Array.new(#{sz})" }
        ret << "#{sz}.times do |i|"
        ret << "  #{dcl} = #{expr}.each_slice(#{names.size}).to_a.transpose"
        ret << 'end'
        ret
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

      def gen_cmb_expr(item)
        case item
        when :number
          'gets.split.map(&:to_i)'
        when :string, :char
          'gets.chomp.split'
        end
      end
    end
  end
end
