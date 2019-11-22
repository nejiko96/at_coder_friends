# frozen_string_literal: true
module AtCoderFriends
  module Generator
    Attributes = Struct.new(:file_ext, :default_template, :interactive_template)

    # common behavior of generators
    class Base
      attr_reader :cfg, :pbm

      def initialize(cfg = nil)
        @cfg = cfg || {}
      end

      def process(pbm)
        pbm.add_src(attrs.file_ext, generate(pbm))
      end

      def generate(pbm)
        @pbm = pbm
        render(File.read(select_template))
      end

      def embed_lines(src, pat, lines)
        re = Regexp.escape(pat)
        src.gsub(
          /^(.*)#{re}(.*)$/,
          lines.compact.map { |s| '\1' + s + '\2' }.join("\n")
        )
      end

      def select_template(interactive = pbm.options.interactive)
        interactive ? select_interactive : select_default
      end

      def select_default
        cfg['default_template'] || attrs.default_template
      end

      def select_interactive
        cfg['interactive_template'] || attrs.interactive_template
      end

      def attrs
        raise AppError, 'no implementation.'
      end

      def render(_src)
        raise AppError, 'no implementation.'
      end
    end
  end
end
