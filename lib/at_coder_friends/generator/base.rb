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
        pbm.add_src(config_file_ext, generate(pbm))
      end

      def generate(pbm)
        @pbm = pbm
        template = File.read(config_template)
        src = ERB.new(template, trim_mode: '-').result(binding)
        src = render(src) if respond_to?(:render)
        src
      end

      def fragments
        @fragments ||= YAML.load_file(config_fragments)
      end

      def config_file_ext
        cfg['file_ext']&.to_sym || attrs.file_ext
      end

      def config_template
        template = cfg['template'] || cfg['default_template'] || attrs.template
        template.sub(/\A@/, TMPL_DIR)
      end

      def config_fragments
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
    end

    module ConstFragmentMixin
      def gen_consts
        pbm.constants.map { |c| gen_const(c) }
      end

      def gen_const(c)
        ConstFragment.new(c, fragments['constant']).generate
      end
    end

    module DeclFragmentMixin
      def gen_decls
        pbm.formats.map { |inpdef| gen_decl(inpdef).split("\n") }.flatten
      end

      def gen_decl(inpdef)
        InputFormatFragment.new(inpdef, fragments['declaration']).generate
      end
    end

    module InputFragmentMixin
      def gen_inputs
        pbm.formats.map { |inpdef| gen_input(inpdef).split("\n") }.flatten
      end

      def gen_input(inpdef)
        InputFormatFragment.new(inpdef, fragments['input']).generate
      end
    end
  end
end
