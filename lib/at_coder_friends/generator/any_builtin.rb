# frozen_string_literal: true

module AtCoderFriends
  module Generator
    # generates source from template
    class AnyBuiltin < Base
      include ConstFragmentMixin
      include DeclFragmentMixin

      ACF_HOME = File.realpath(File.join(__dir__, '..', '..', '..'))
      TMPL_DIR = File.join(ACF_HOME, 'templates')
      TEMPLATE = File.join(TMPL_DIR, 'any_builtin.md.erb')
      FRAGMENTS = File.join(TMPL_DIR, 'any_builtin_fragments.yml')
      ATTRS = Attributes.new(:md, TEMPLATE, FRAGMENTS)

      def attrs
        ATTRS
      end
    end
  end
end
