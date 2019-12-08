# frozen_string_literal: true

module AtCoderFriends
  module Parser
    InputFormatMatcher = Struct.new(
      :container, :item,
      :pat, :gen_names, :gen_pat2
    ) do
      attr_reader :names, :size, :delim

      def initialize(container, item, pat, gen_names, gen_pat2 = nil)
        super(container, item, pat, gen_names, gen_pat2)
      end

      def match(str, delim)
        return false unless (m1 = pat.match(str))

        @names = gen_names.call(m1)
        @pat2 = gen_pat2&.call(names)
        @size = m1.names.include?('sz') && m1['sz'] || ''
        @delim = delim
        true
      end

      def match2(str)
        return false unless @pat2
        return true if /\A\.+\z/ =~ str
        return false unless (m2 = @pat2.match(str))

        m2.names.include?('sz') && @size = m2['sz']
        true
      end

      def to_inpdef
        Problem::InputFormat.new(
          container, item, names, size, delim
        )
      end
    end

    module InputFormatConstants
      SECTIONS = [Problem::SECTION_IN_FMT, Problem::SECTION_IO_FMT].freeze
      RE_0 = /[0-9]+/.freeze
      RE_00 = /[01][,_]?[01]/.freeze
      RE_99 = /[0-9]+[,_]?[0-9]+/.freeze
      RE_ITEM = /\{*[A-Za-z]+(?:_[A-Za-z]+)*\}*/.freeze
      RE_IX = /(_\S+?|\{\S+?\})/.freeze
      RE_IX_0 = /(_\{*#{RE_0}\}*|\{+#{RE_0}\}+)/.freeze
      RE_IX_00 = /(_\{*#{RE_00}\}*|\{+#{RE_00}\}+)/.freeze
      RE_IX_99 = /(_\{*#{RE_99}\}*|\{+#{RE_99}\}+)/.freeze
      RE_SZ = /(_(?<sz>\S+?)|\{(?<sz>\S+?)\})/.freeze
      RE_SZ_REF = '(_\{*\k<sz>\}*|\{+\k<sz>\}+)'
      RE_SZ2_0 = /(_\{*(?<sz2>#{RE_0})\}*|\{+(?<sz2>#{RE_0})\}+)/.freeze
      RE_SZ2_REF = '(_\{*\k<sz2>\}*|\{+\k<sz2>\}+)'
      RE_SZ_0 = /(_\{*(?<sz>#{RE_0})\}*|\{+(?<sz>#{RE_0})\}+)/.freeze
      RE_SZ_00 = /(_\{*(?<sz>#{RE_00})\}*|\{+(?<sz>#{RE_00})\}+)/.freeze
      RE_SZ_99 = /(_\{*(?<sz>#{RE_99})\}*|\{+(?<sz>#{RE_99})\}+)/.freeze
      RE_SINGLE = /[A-Za-z{][A-Za-z_0-9{}]*/.freeze
      RE_BLOCK = /(?<bl>\{(?:[^{}]|\g<bl>)*\})/.freeze
      MATRIX_MATCHER = InputFormatMatcher.new(
        :matrix, :number,
        /
          \A (?<v>#{RE_ITEM})#{RE_IX_00} (\s+(\.+|\k<v>#{RE_IX}))*
          \s+\k<v>#{RE_SZ} \z
        /x,
        ->(m) { [m[:v]] },
        lambda { |(v)|
          /
            \A #{v}#{RE_IX} (\s+(\.+|#{v}#{RE_IX}))*
            \s+(\.+|#{v}#{RE_SZ}) \z
          /x
        }
      )
      MATRIX_CHAR_MATCHER = InputFormatMatcher.new(
        :matrix, :char,
        /
          \A (?<v>#{RE_ITEM})#{RE_IX_00} (\s*\.+\s*|\k<v>#{RE_IX})*
          \k<v>#{RE_SZ} \z
        /x,
        ->(m) { [m[:v]] },
        lambda { |(v)|
          /
            \A (#{v}#{RE_IX})+ (\s*\.+\s*|#{v}#{RE_IX})*
            (\s*\.+\s*|#{v}#{RE_SZ}) \z
          /x
        }
      )
      HARRAY_MATCHER = InputFormatMatcher.new(
        :harray, :number,
        /
          \A (?<v>#{RE_ITEM})#{RE_IX_0} (\s+(\.+|\k<v>#{RE_IX}))*
          \s+\k<v>#{RE_SZ} \z
        /x,
        ->(m) { [m[:v]] }
      )
      HARRAY_CHAR_MATCHER = InputFormatMatcher.new(
        :harray, :char,
        /
          \A (?<v>#{RE_ITEM})#{RE_IX_0} (\s*\.+\s*|\k<v>#{RE_IX})*
          \k<v>#{RE_SZ} \z
        /x,
        ->(m) { [m[:v]] }
      )
      VARRAY_MATRIX_MATCHER = InputFormatMatcher.new(
        :varray_matrix, :number,
        /
          \A (?<vs>#{RE_ITEM}#{RE_SZ_0} (\s+#{RE_ITEM}#{RE_SZ_REF})*)
          \s+(?<m>#{RE_ITEM})#{RE_IX_00} (\s+(\.+|\k<m>#{RE_IX}))*
          \s+\k<m>#{RE_SZ} \z
        /x,
        ->(m) { [*m[:vs].split.map { |w| w.scan(RE_ITEM)[0] }, m[:m]] },
        lambda { |vs|
          ws = vs[0..-2].map { |v| v + RE_IX.source }.join('\s+')
          m = vs[-1]
          /
            \A #{ws} \s+#{m}#{RE_IX} (\s+(\.+|#{m}#{RE_IX}))*
            \s+(\.+|#{m}#{RE_SZ}) \z
          /x
        }
      )
      VARRAY_MATRIX_CHAR_MATCHER = InputFormatMatcher.new(
        :varray_matrix, :char,
        /
          \A (?<vs>#{RE_ITEM}#{RE_SZ_0} (\s+#{RE_ITEM}#{RE_SZ_REF})*)
          \s+(?<m>#{RE_ITEM})#{RE_IX_00} (\s*\.+\s*|\k<m>#{RE_IX})*
          \k<m>#{RE_SZ} \z
        /x,
        ->(m) { [*m[:vs].split.map { |w| w.scan(RE_ITEM)[0] }, m[:m]] },
        lambda { |vs|
          ws = vs[0..-2].map { |v| v + RE_IX.source }.join('\s+')
          m = vs[-1]
          /
            \A #{ws} \s+#{m}#{RE_IX} (\s*\.+\s*|#{m}#{RE_IX})*
            (\s*\.+\s*|#{m}#{RE_SZ}) \z
          /x
        }
      )
      MATRIX_VARRAY_MATCHER = InputFormatMatcher.new(
        :matrix_varray, :number,
        /
          \A (?<m>#{RE_ITEM})#{RE_IX_00} (\s+(\.+|\k<m>#{RE_IX}))*
          \s+\k<m>#{RE_SZ}
          \s+(?<vs>#{RE_ITEM}#{RE_SZ2_0} (\s+#{RE_ITEM}#{RE_SZ2_REF})*) \z
        /x,
        ->(m) { [m[:m], *m[:vs].split.map { |w| w.scan(RE_ITEM)[0] }] },
        lambda { |vs|
          m = vs[0]
          ws = vs[1..-1].map { |v| v + RE_IX.source }.join('\s+')
          /
            \A #{m}#{RE_IX} (\s+(\.+|#{m}#{RE_IX}))*
            \s+(\.+|#{m}#{RE_SZ}) \s+#{ws} \z
          /x
        }
      )
      VMATRIX_MATCHER = InputFormatMatcher.new(
        :vmatrix, :number,
        /
          \A #{RE_ITEM}#{RE_SZ_00} (\s+#{RE_ITEM}#{RE_SZ_REF})* \z
        /x,
        ->(m) { m[0].split.map { |w| w.scan(RE_ITEM)[0] } },
        lambda { |vs|
          ws = [
            vs[0] + RE_SZ.source,
            *vs[1..-1]&.map { |v| v + RE_IX.source }
          ].join('\s+')
          /\A#{ws}\z/
        }
      )
      HMATRIX_MATCHER = InputFormatMatcher.new(
        :hmatrix, :number,
        /
          \A #{RE_ITEM}#{RE_IX_00} (\s+(\.+|#{RE_ITEM}#{RE_IX_99}))*
          \s+#{RE_ITEM}#{RE_SZ_99} \z
        /x,
        ->(m) { m[0].split.map { |w| w.scan(RE_ITEM)[0] }.uniq },
        lambda { |vs|
          p vs
          ws1 = vs.map { |v| v + RE_IX.source }.join('\s+')
          ws2 = [
            vs[0] + RE_SZ.source,
            *vs[1..-1]&.map { |v| v + RE_IX.source }
          ].join('\s+')
          /
            \A #{ws1} (\s+(\.+|#{ws1}))* \s+(\.+|#{ws2}) \z
          /x
        }
      )
      VARRAY_MATCHER = InputFormatMatcher.new(
        :varray, :number,
        /
          \A #{RE_ITEM}#{RE_SZ_0} (\s+#{RE_ITEM}#{RE_SZ_REF})* \z
        /x,
        ->(m) { m[0].split.map { |w| w.scan(RE_ITEM)[0] } },
        lambda { |vs|
          ws = [
            vs[0] + RE_SZ.source,
            *vs[1..-1]&.map { |v| v + RE_IX.source }
          ].join('\s+')
          /\A#{ws}\z/
        }
      )
      SINGLE_MATCHER = InputFormatMatcher.new(
        :single, :number,
        /\A(.*\s)?#{RE_SINGLE}(\s.*)?\z/,
        ->(m) { m[0].split.select { |w| w =~ /\A#{RE_SINGLE}\z/ } }
      )
      MATCHERS = [
        MATRIX_MATCHER,
        MATRIX_CHAR_MATCHER,
        HARRAY_MATCHER,
        HARRAY_CHAR_MATCHER,
        VARRAY_MATRIX_MATCHER,
        VARRAY_MATRIX_CHAR_MATCHER,
        MATRIX_VARRAY_MATCHER,
        VMATRIX_MATCHER,
        HMATRIX_MATCHER,
        VARRAY_MATCHER,
        SINGLE_MATCHER
      ].freeze
      DIMENSION_TBL = {
        single: 0,
        varray: 1,
        harray: 1,
        matrix: 2,
        varray_matrix: 2,
        matrix_varray: 2,
        vmatrix: 2,
        hmatrix: 2
      }.freeze
    end

    # parses input data format and generates input definitons
    module InputFormat
      include InputFormatConstants

      module_function

      def process(pbm)
        return unless (str = find_fmt(pbm))

        inpdefs = parse(str)
        pbm.formats_src = inpdefs
      end

      def find_fmt(pbm)
        str = nil
        SECTIONS.any? do |key|
          str = pbm.sections[key]&.code_block_html
          str && !str.empty?
        end
        str
      end

      def parse(str)
        lines = normalize_fmt(str)
        inpdefs = parse_fmt(lines)
        normalize_defs(inpdefs)
        inpdefs
      end

      # 1) &npsp; , fill-width space -> half width space
      # 2) {i, j}->{i,j} for nested {}
      def normalize_fmt(str)
        str
          .tr('０-９Ａ-Ｚａ-ｚ', '0-9A-Za-z')
          .gsub(/[[:space:]]/) { |c| c.gsub(/[^\n]/, ' ') } # 1)
          .gsub(%r{<var>([^<>]+)</var>}i, '\1') # <sub><var>N</var></sub>
          .gsub(%r{<sup>([^<>]+)</sup>}i, '^\1')
          .gsub(%r{<sub>([^<>]+)</sub>}i, '_{\1}')
          .gsub(%r{<sub>([^<>]+)</sub>}i, '_{\1}') # for nested<sub>
          .gsub(/<("[^"]*"|'[^']*'|[^'"<>])*>/, '')
          .gsub('&amp;', '&')
          .gsub('&gt;', '>')
          .gsub('&lt;', '<')
          .gsub('\\ ', ' ')
          .gsub('\\(', '')
          .gsub('\\)', '')
          .gsub('\\lvert', '|')
          .gsub('\\rvert', '|')
          .gsub('\\mathit', '')
          .gsub('\\times', '*')
          .gsub(/\\begin(\{[^{}]*\})*/, '')
          .gsub(/\\end(\{[^{}]*\})*/, '')
          .gsub(/\\[cdlv]?dots/, '..')
          .gsub(/\{\}/, ' ')
          .gsub('−', '-') # full width hyphen
          .gsub(/[・．：‥⋮︙…]+/, '..')
          .gsub(/[\\$']/, '') # s' -> s
          .gsub(/[&~|]/, ' ') # |S| -> S
          .gsub(/^\s*[.:][\s.:]*$/, '..')
          .tr('()', '{}')
          .gsub(/#{RE_BLOCK}/) { |w| w.delete(' ') } # 2)
          .split("\n")
          .map do |line|
            [
              # a-b, a/b, a:b -> a b
              line.gsub(%r{[-/:](#{RE_SINGLE})}, ' \1').strip,
              '-:/'.chars.select { |c| line =~ /#{c}#{RE_SINGLE}/ }.join
            ]
          end
      end

      def parse_fmt(lines)
        matcher = nil
        (lines + [['', '']]).each_with_object([]) do |(line, delim), ret|
          if matcher
            next if matcher.match2(line)

            ret << matcher.to_inpdef
          end
          if (matcher = MATCHERS.find { |m| m.match(line, delim) })
          elsif !line.empty?
            puts "unknown format: #{line}"
            ret << Problem::InputFormat.new(:unknown, line)
          end
        end
      end

      def normalize_defs(inpdefs)
        inpdefs.each do |inpdef|
          inpdef.names = normalize_names(inpdef.names)
          inpdef.size = normalize_size(inpdef.container, inpdef.size)
        end
      end

      def normalize_names(names)
        return names unless names.is_a?(Array)

        names.map { |nm| nm.delete('{}').gsub(/(\A_+|_+\z)/, '') }
      end

      # 1) split size by container dimension
      # 2) remove extra underscores, N-1 -> N
      def normalize_size(container, size)
        (
          case DIMENSION_TBL[container]
          when 2
            split_size(size)
          when 1
            [size]
          when 0
            []
          end
        )
        &.map { |w| w.delete('{},').gsub(/(\A_+|(_|-1)+\z)/, '') }
      end

      def split_size(str)
        str = str.gsub(/(\A\{|\}\z)/, '') while str =~ /\A#{RE_BLOCK}\z/

        sz = str.split(',')
        return sz if sz.size == 2

        sz = str.scan(/(?<nbl>[^{}]+)|#{RE_BLOCK}/).flatten.compact
        return sz if sz.size == 2

        str = str.delete('{},')

        sz = str.scan(/[^_](?:_[^_])?/)
        return sz if sz.size == 2

        sz = str.split('_')
        return sz if sz.size == 2

        [str[0] || '_', str[1..-1] || '_']
      end
    end
  end
end
