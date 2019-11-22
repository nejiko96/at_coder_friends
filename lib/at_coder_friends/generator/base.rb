# frozen_string_literal: true

require 'erb'

module AtCoderFriends
  module Generator
    # common behavior of generators
    class Base
      Attributes = Struct.new(:file_ext, :default_template)

      attr_reader :cfg, :pbm

      def initialize(cfg = nil)
        @cfg = cfg || {}
      end

      def process(pbm)
        pbm.add_src(attrs.file_ext, generate(pbm))
      end

      def generate(pbm)
        @pbm = pbm
        src = File.read(select_template)
        src = ERB.new(src).result(binding)
        render(src)
      end

      def embed_lines(src, pat, lines)
        re = Regexp.escape(pat)
        src.gsub(
          /^(.*)#{re}(.*)$/,
          lines.compact.map { |s| '\1' + s + '\2' }.join("\n")
        )
      end

      def select_template
        cfg['default_template'] || attrs.default_template
      end
    end
  end
end
