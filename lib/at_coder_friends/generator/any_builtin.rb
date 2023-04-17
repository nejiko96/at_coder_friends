# frozen_string_literal: true

module AtCoderFriends
  module Generator
    # generates any language file from template
    class AnyBuiltin < Base
      ACF_HOME = File.realpath(File.join(__dir__, '..', '..', '..'))
      TMPL_DIR = File.join(ACF_HOME, 'templates')
      DEFAULT_TMPL = File.join(TMPL_DIR, 'any_builtin.txt.erb')
      ATTRS = Attributes.new(:txt, DEFAULT_TMPL)

      def attrs
        ATTRS
      end
    end
  end
end
