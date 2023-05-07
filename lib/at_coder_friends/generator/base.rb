# frozen_string_literal: true

require 'yaml'
require 'erb'

module AtCoderFriends
  module Generator
    Attributes = Struct.new(:file_ext, :template, :fragments)
    module ProblemWrapperMixin
      # delegate method calls to pbm
      def method_missing(name, *args, &block)
        if @pbm.respond_to?(name)
          @pbm.send(name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        @pbm.respond_to?(name, include_private) || super
      end

      def inpdefs
        formats
      end
    end

    # common behavior of generators
    class Base
      include ProblemWrapperMixin

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

    module CommonFragmentMixin
      def gen_consts
        constants.map { |c| gen_const(c) }
      end

      def gen_const(c)
        ConstFragment.new(c, fragments['constant']).generate
      end

      def gen_decls
        inpdefs.map { |inpdef| gen_decl(inpdef).split("\n") }.flatten
      end

      def gen_decl(inpdef)
        InputFormatFragment.new(inpdef, fragments['declaration']).generate
      end
    end
  end
end
