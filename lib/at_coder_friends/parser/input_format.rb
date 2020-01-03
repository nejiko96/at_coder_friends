# frozen_string_literal: true

module AtCoderFriends
  module Parser
    module InputFormatConstants
      SECTIONS = [Problem::SECTION_IN_FMT, Problem::SECTION_IO_FMT].freeze
      DELIMS = %w[- / :].freeze
      RE_SINGLE = /[A-Za-z{][A-Za-z_0-9{}]*/.freeze
      RE_ITEM = /\{*[A-Za-z]+(?:_[A-Za-z]+)*\}*/.freeze
      RE_0 = /[0-9]+/.freeze
      RE_00 = /[01][,_]?[01]/.freeze
      RE_99 = /[0-9]+[,_]?[0-9]+/.freeze
      ADD_TAG = ->(tag, re) { /(?<#{tag}>#{re})/ }
      TO_SUFFIX = ->(re) { /(_\{*#{re}\}*|\{+#{re}\}+)/ }
      TO_SUFFIX_STR = ->(str) { "(_\\{*#{str}\\}*|\\{+#{str}\\}+)" }
      RE_IX = TO_SUFFIX[/\S+?/]
      RE_IX_0 = TO_SUFFIX[ADD_TAG['ix0', RE_0]]
      RE_IX_00 = TO_SUFFIX[ADD_TAG['ix0', RE_00]]
      RE_IX_99 = TO_SUFFIX[RE_99]
      RE_SZ = TO_SUFFIX[ADD_TAG['sz', /\S+?/]]
      RE_SZ_0 = TO_SUFFIX[ADD_TAG['sz', RE_0]]
      RE_SZ_00 = TO_SUFFIX[ADD_TAG['sz', RE_00]]
      RE_SZ_99 = TO_SUFFIX[ADD_TAG['sz', RE_99]]
      RE_SZ_REF = TO_SUFFIX_STR['\k<sz>']
      RE_SZ2_0 = TO_SUFFIX[ADD_TAG['sz2', RE_0]]
      RE_SZ2_REF = TO_SUFFIX_STR['\k<sz2>']
      RE_BLOCK = /(?<bl>\{(?:[^{}]|\g<bl>)*\})/.freeze
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

    # utilities for input format parser
    module InputFormatUtils
      include InputFormatConstants

      # 1) &npsp;, fill-width space -> half width space
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
          .map(&:strip)
      end

      def extract_delim(str)
        # a-b, a/b, a:b -> a b
        str = str.dup
        dlms =
          DELIMS.select { |c| str.gsub!(/#{c}(#{RE_SINGLE})/, ' \1') }.join
        [str, dlms]
      end

      def normalize_name(s)
        s.delete('{},').gsub(/(\A_+|_+\z)/, '')
      end

      def normalize_names(names)
        names.map { |nm| normalize_name(nm) }
      end

      def normalize_size(container, size, ix0)
        sz = size_array(container, size)
        sz0 = size_array(container, ix0)

        sz.map.with_index do |s, i|
          if sz0[i] == '0'
            # 0 -> 1,  N-1 -> N, N-2 -> N-1 if 0 origin
            s.gsub(/\A0\z/, '1').gsub(/-1\z/, '').gsub(/-2\z/, '-1')
          else
            s
          end
        end
      end

      # split size by container dimension
      def size_array(container, size)
        (
          case DIMENSION_TBL[container]
          when 2
            split_size(size)
          when 1
            [size]
          when 0
            []
          end
        ).map { |s| normalize_name(s) }
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

    # holds regular expressions and matches it with input format string
    class InputFormatMatcher
      include InputFormatUtils

      attr_reader :container, :item, :pat, :gen_names, :gen_pat2
      attr_reader :names, :pat2, :size, :delim, :ix0

      def initialize(
        container: nil, item: nil,
        pat: nil, gen_names: nil, gen_pat2: nil
      )
        @container = container
        @item = item
        @pat = pat
        @gen_names = gen_names
        @gen_pat2 = gen_pat2
      end

      def match(str)
        str, dlm = extract_delim(str)
        return false unless (m1 = pat.match(str))

        @names = gen_names.call(m1)
        @pat2 = gen_pat2&.call(names)
        @size = m1.names.include?('sz') && m1['sz'] || ''
        @ix0 = m1.names.include?('ix0') && m1['ix0'] || size
        @delim = dlm
        true
      end

      def match2(str)
        return false unless pat2

        str, _dlm = extract_delim(str)
        return true if /\A\.+\z/ =~ str
        return false unless (m2 = pat2.match(str))

        m2.names.include?('sz') && @size = m2['sz']
        true
      end

      def to_inpdef
        Problem::InputFormat.new(
          container: container, item: item,
          names: normalize_names(names),
          size: normalize_size(container, size, ix0),
          delim: delim
        )
      end
    end

    # matcher constants
    module InputFormatMatcherConstants
      include InputFormatConstants

      MATRIX_MATCHER = InputFormatMatcher.new(
        container: :matrix,
        pat:
          /
            \A
            (?<v>#{RE_ITEM})#{RE_IX_00}
            (\s+(\.+|\k<v>#{RE_IX}))*
            \s+\k<v>#{RE_SZ}
            \z
          /x,
        gen_names: ->(m) { [m[:v]] },
        gen_pat2:
          lambda { |(v)|
            /
              \A
              #{v}#{RE_IX}
              (\s+(\.+|#{v}#{RE_IX}))*
              \s+(\.+|#{v}#{RE_SZ})
              \z
            /x
          }
      )
      MATRIX_CHAR_MATCHER = InputFormatMatcher.new(
        container: :matrix,
        item: :char,
        pat:
          /
            \A
            (?<v>#{RE_ITEM})#{RE_IX_00}
            (\s*\.+\s*|\k<v>#{RE_IX})*
            \k<v>#{RE_SZ}
            \z
          /x,
        gen_names: ->(m) { [m[:v]] },
        gen_pat2:
          lambda { |(v)|
            /
              \A
              (#{v}#{RE_IX})+
              (\s*\.+\s*|#{v}#{RE_IX})*
              (\s*\.+\s*|#{v}#{RE_SZ})
              \z
            /x
          }
      )
      HARRAY_MATCHER = InputFormatMatcher.new(
        container: :harray,
        pat:
          /
            \A
            (?<v>#{RE_ITEM})#{RE_IX_0}
            (\s+(\.+|\k<v>#{RE_IX}))*
            \s+\k<v>#{RE_SZ}
            \z
          /x,
        gen_names: ->(m) { [m[:v]] }
      )
      HARRAY_CHAR_MATCHER = InputFormatMatcher.new(
        container: :harray,
        item: :char,
        pat:
          /
            \A
            (?<v>#{RE_ITEM})#{RE_IX_0}
            (\s*\.+\s*|\k<v>#{RE_IX})*
            \k<v>#{RE_SZ}
            \z
          /x,
        gen_names: ->(m) { [m[:v]] }
      )
      VARRAY_MATRIX_MATCHER = InputFormatMatcher.new(
        container: :varray_matrix,
        pat:
          /
            \A
            (?<vs>#{RE_ITEM}#{RE_SZ2_0} (\s+#{RE_ITEM}#{RE_SZ2_REF})*)
            \s+(?<m>#{RE_ITEM})#{RE_IX_00}
            (\s+(\.+|\k<m>#{RE_IX}))*
            \s+\k<m>#{RE_SZ}
            \z
          /x,
        gen_names:
          ->(m) { [*m[:vs].split.map { |w| w.scan(RE_ITEM)[0] }, m[:m]] },
        gen_pat2:
          lambda { |vs|
            ws = vs[0..-2].map { |v| v + RE_IX.source }.join('\s+')
            m = vs[-1]
            /
              \A
              #{ws}
              \s+#{m}#{RE_IX}
              (\s+(\.+|#{m}#{RE_IX}))*
              \s+(\.+|#{m}#{RE_SZ})
              \z
            /x
          }
      )
      VARRAY_MATRIX_CHAR_MATCHER = InputFormatMatcher.new(
        container: :varray_matrix,
        item: :char,
        pat:
          /
            \A
            (?<vs>#{RE_ITEM}#{RE_SZ2_0} (\s+#{RE_ITEM}#{RE_SZ2_REF})*)
            \s+(?<m>#{RE_ITEM})#{RE_IX_00}
            (\s*\.+\s*|\k<m>#{RE_IX})*
            \k<m>#{RE_SZ} \z
          /x,
        gen_names:
          ->(m) { [*m[:vs].split.map { |w| w.scan(RE_ITEM)[0] }, m[:m]] },
        gen_pat2:
          lambda { |vs|
            ws = vs[0..-2].map { |v| v + RE_IX.source }.join('\s+')
            m = vs[-1]
            /
              \A
              #{ws}
              \s+#{m}#{RE_IX}
              (\s*\.+\s*|#{m}#{RE_IX})*
              (\s*\.+\s*|#{m}#{RE_SZ})
              \z
            /x
          }
      )
      MATRIX_VARRAY_MATCHER = InputFormatMatcher.new(
        container: :matrix_varray,
        pat:
          /
            \A
            (?<m>#{RE_ITEM})#{RE_IX_00}
            (\s+(\.+|\k<m>#{RE_IX}))*
            \s+\k<m>#{RE_SZ}
            \s+(?<vs>#{RE_ITEM}#{RE_SZ2_0} (\s+#{RE_ITEM}#{RE_SZ2_REF})*)
            \z
          /x,
        gen_names:
          ->(m) { [m[:m], *m[:vs].split.map { |w| w.scan(RE_ITEM)[0] }] },
        gen_pat2:
          lambda { |vs|
            m = vs[0]
            ws = vs[1..-1].map { |v| v + RE_IX.source }.join('\s+')
            /
              \A
              #{m}#{RE_IX}
              (\s+(\.+|#{m}#{RE_IX}))*
              \s+(\.+|#{m}#{RE_SZ})
              \s+#{ws}
              \z
            /x
          }
      )
      VMATRIX_MATCHER = InputFormatMatcher.new(
        container: :vmatrix,
        pat:
          /
            \A
            #{RE_ITEM}#{RE_SZ_00} (\s+#{RE_ITEM}#{RE_SZ_REF})*
            \z
          /x,
        gen_names: ->(m) { m[0].split.map { |w| w.scan(RE_ITEM)[0] } },
        gen_pat2:
          lambda { |vs|
            ws = [
              vs[0] + RE_SZ.source,
              *vs[1..-1]&.map { |v| v + RE_IX.source }
            ].join('\s+')
            /\A#{ws}\z/
          }
      )
      HMATRIX_MATCHER = InputFormatMatcher.new(
        container: :hmatrix,
        pat:
          /
            \A
            #{RE_ITEM}#{RE_IX_00}
            (\s+(\.+|#{RE_ITEM}#{RE_IX_99}))*
            \s+#{RE_ITEM}#{RE_SZ_99}
            \z
          /x,
        gen_names:
          ->(m) { m[0].split.map { |w| w.scan(RE_ITEM)[0] }.uniq },
        gen_pat2:
          lambda { |vs|
            ws1 = vs.map { |v| v + RE_IX.source }.join('\s+')
            ws2 = [
              vs[0] + RE_SZ.source,
              *vs[1..-1]&.map { |v| v + RE_IX.source }
            ].join('\s+')
            /
              \A
              #{ws1} (\s+(\.+|#{ws1}))* \s+(\.+|#{ws2})
              \z
            /x
          }
      )
      VARRAY_MATCHER = InputFormatMatcher.new(
        container: :varray,
        pat:
          /
            \A
            #{RE_ITEM}#{RE_SZ_0} (\s+#{RE_ITEM}#{RE_SZ_REF})*
            \z
          /x,
        gen_names:
          ->(m) { m[0].split.map { |w| w.scan(RE_ITEM)[0] } },
        gen_pat2:
          lambda { |vs|
            ws = [
              vs[0] + RE_SZ.source,
              *vs[1..-1]&.map { |v| v + RE_IX.source }
            ].join('\s+')
            /\A#{ws}\z/
          }
      )
      SINGLE_MATCHER = InputFormatMatcher.new(
        container: :single,
        pat: /\A(.*\s)?#{RE_SINGLE}(\s.*)?\z/,
        gen_names: ->(m) { m[0].split.select { |w| w =~ /\A#{RE_SINGLE}\z/ } }
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
    end

    # parses input data format and generates input definitons
    module InputFormat
      extend InputFormatUtils
      include InputFormatConstants
      include InputFormatMatcherConstants

      module_function

      def process(pbm)
        return unless (str = find_fmt(pbm))

        inpdefs = parse(str)
        pbm.formats_src = inpdefs
      end

      def find_fmt(pbm)
        str = nil
        SECTIONS.any? do |key|
          (str = pbm.sections[key]&.code_block_html) && !str.empty?
        end
        str
      end

      def parse(str)
        lines = normalize_fmt(str)
        parse_fmt(lines)
      end

      def parse_fmt(lines)
        matcher = nil
        (lines + ['']).each_with_object([]) do |line, ret|
          if matcher
            next if matcher.match2(line)

            ret << matcher.to_inpdef
          end
          if (matcher = MATCHERS.find { |m| m.match(line) })
          elsif !line.empty?
            puts "unknown format: #{line}"
            ret << unknown_fmt(line)
          end
        end
      end

      def unknown_fmt(line)
        Problem::InputFormat.new(container: :unknown, item: line)
      end
    end
  end
end
