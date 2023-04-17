# frozen_string_literal: true

require 'erb'

module AtCoderFriends
  module Generator
    Attributes = Struct.new(:file_ext, :default_template)

    # common behavior of generators
    class Base
      attr_reader :cfg, :pbm

      def initialize(cfg = nil)
        @cfg = cfg || {}
      end

      def process(pbm)
        pbm.add_src(select_file_ext, generate(pbm))
      end

      def generate(pbm)
        @pbm = pbm
        src = File.read(select_template)
        src = ERB.new(src, safe_level = nil, trim_mode = '-').result(binding)
        src = render(src) if respond_to?(:render)
        src
      end

      def select_file_ext
        cfg['file_ext'] || attrs.file_ext
      end

      def select_template
        cfg['default_template'] || attrs.default_template
      end

      def embed_lines(src, pat, lines)
        re = Regexp.escape(pat)
        src.gsub(
          /^(.*)#{re}(.*)$\n/,
          lines.compact.map { |s| "\\1#{s}\\2\n" }.join
        )
      end
    end
  end
end
