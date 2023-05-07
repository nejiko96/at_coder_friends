# frozen_string_literal: true

module AtCoderFriends
  module Generator
    # generates Ruby source from problem description
    class RubyBuiltin < Base
      include ConstFragmentMixin
      include DeclFragmentMixin

      ACF_HOME = File.realpath(File.join(__dir__, '..', '..', '..'))
      TMPL_DIR = File.join(ACF_HOME, 'templates')
      TEMPLATE = File.join(TMPL_DIR, 'ruby_builtin.rb.erb')
      FRAGMENTS = File.realpath(File.join(TMPL_DIR, 'ruby_builtin_fragments.yml'))
      ATTRS = Attributes.new(:rb, TEMPLATE, FRAGMENTS)

      def attrs
        ATTRS
      end

      def constants
        super.select { |c| c.type == :mod }
      end

      # deprecated, use ERB syntax
      def render(src)
        src = embed_lines(src, '### CONSTS ###', gen_consts)
        embed_lines(src, '### DCLS ###', gen_decls)
      end
    end
  end
end
