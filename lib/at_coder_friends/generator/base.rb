# frozen_string_literal: true

require 'yaml'
require 'erb'

module AtCoderFriends
  module Generator
    Attributes = Struct.new(:file_ext, :template, :fragments)

    # common behavior of generators
    class Base
      ACF_HOME = File.realpath(File.join(__dir__, '..', '..', '..'))
      TMPL_DIR = File.join(ACF_HOME, 'templates')

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
        src = ERB.new(src, trim_mode: '-').result(binding)
        src = render(src) if respond_to?(:render)
        src
      end

      def select_file_ext
        cfg['file_ext']&.to_sym || attrs.file_ext
      end

      def select_template
        template = cfg['template'] || cfg['default_template'] || attrs.template
        template.sub(/\A@/, TMPL_DIR)
      end

      def select_fragments
        fragments = cfg['fragments'] || attrs.fragments
        fragments.sub(/\A@/, TMPL_DIR)
      end

      # deprecated, use ERB syntax
      def embed_lines(src, pat, lines)
        re = Regexp.escape(pat)
        src.gsub(
          /^(.*)#{re}(.*)$\n/,
          lines.compact.map { |s| "\\1#{s}\\2\n" }.join
        )
      end

      def fragments
        @fragments ||= YAML.load_file(select_fragments)
      end
    end
  end
end
