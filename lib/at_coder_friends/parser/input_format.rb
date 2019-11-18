# frozen_string_literal: true

module AtCoderFriends
  module Parser
    InputFormatMatcher = Struct.new(
      :container, :item,
      :pat, :gen_names, :gen_pat2
    ) do
      attr_reader :names, :size

      def match(str)
        return false unless (m1 = pat.match(str))

        @names = gen_names.call(m1)
        @pat2 = gen_pat2&.call(names)
        @size = m1.names.include?('sz') && m1['sz'] || ''
        true
      end

      def match2(str)
        return false unless @pat2
        return true if /\A\.+\z/ =~ str
        return false unless (m2 = @pat2.match(str))

        m2.names.include?('sz') && @size = m2['sz']
        true
      end
    end

    module InputFormatConstants
      SECTIONS = [
        Problem::SECTION_IN_FMT,
        Problem::SECTION_IO_FMT
      ].freeze
      RE_ITEM = /\{*[A-Za-z]+(?:_[A-Za-z]+)*\}*/.freeze
      RE_IX_00 = /(_\{*[01][,_]?[01]\}*|\{+[01][,_]?[01]\}+)/.freeze
      RE_IX_0 = /(_\{*[0-9]+\}*|\{+[0-9]+\}+)/.freeze
      RE_IX = /(_\S+?|\{\S+?\})/.freeze
      RE_SZ = /(_(?<sz>\S+?)|\{(?<sz>\S+?)\})/.freeze
      RE_SZ_0 = /(_\{*(?<sz>[0-9]+)\}*|\{+(?<sz>[0-9]+)\}+)/.freeze
      RE_SZ_REF = '(_\{*\k<sz>\}*|\{+\k<sz>\}+)'
      RE_SINGLE = /[A-Za-z{][A-Za-z_0-9{}]*/.freeze
      RE_BLOCK = /(?<bl>\{(?:[^{}]|\g<bl>)*\})/.freeze
      MATCHERS = [
        InputFormatMatcher.new(
          :matrix, :number,
          /
            \A
            (?<v>#{RE_ITEM})#{RE_IX_00}
            (\s+(\.+|\k<v>#{RE_IX}))*
            \s+\k<v>#{RE_SZ}
            \z
          /x,
          ->(m) { [m[:v]] },
          lambda { |(v)|
            /
              \A
              #{v}#{RE_IX}
              (\s+(\.+|#{v}#{RE_IX}))*
              \s+(\.+|#{v}#{RE_SZ})
              \z
            /x
          }
        ),
        InputFormatMatcher.new(
          :matrix, :char,
          /
            \A
            (?<v>#{RE_ITEM})#{RE_IX_00}
            (\s*\.+\s*|\k<v>#{RE_IX})*
            \k<v>#{RE_SZ}
            \z
          /x,
          ->(m) { [m[:v]] },
          lambda { |(v)|
            /
              \A
              (#{v}#{RE_IX})+
              (\s*\.+\s*|#{v}#{RE_IX})*
              (\s*\.+\s*|#{v}#{RE_SZ})
              \z
            /x
          }
        ),
        InputFormatMatcher.new(
          :harray, :number,
          /
            \A
            (?<v>#{RE_ITEM})#{RE_IX_0}
            (\s+(\.+|\k<v>#{RE_IX}))*
            \s+\k<v>#{RE_SZ}
            \z
          /x,
          ->(m) { [m[:v]] },
          nil
        ),
        InputFormatMatcher.new(
          :harray, :char,
          /
            \A
            (?<v>#{RE_ITEM})#{RE_IX_0}
            (\s*\.+\s*|\k<v>#{RE_IX})*
            \k<v>#{RE_SZ}
            \z
          /x,
          ->(m) { [m[:v]] },
          nil
        ),
        InputFormatMatcher.new(
          :vmatrix, :number,
          /
            \A
            (?<vs>#{RE_ITEM}#{RE_SZ_0} (\s+#{RE_ITEM}#{RE_SZ_REF})*)
            \s+(?<m>#{RE_ITEM})#{RE_IX_00}
            (\s+(\.+|\k<m>#{RE_IX}))*
            \s+\k<m>#{RE_SZ}
            \z
          /x,
          ->(m) { m[:vs].split.map { |w| w.scan(RE_ITEM)[0] } + [m[:m]] },
          lambda { |vs|
            pat2 = vs[0..-2].map { |v| v + RE_IX.source }.join('\s+')
            m = vs[-1]
            /
              \A
              #{pat2}
              \s+#{m}#{RE_IX}
              (\s+(\.+|#{m}#{RE_IX}))*
              \s+(\.+|#{m}#{RE_SZ})
              \z
            /x
          }
        ),
        InputFormatMatcher.new(
          :vmatrix, :char,
          /
            \A
            (?<vs>#{RE_ITEM}#{RE_SZ_0} (\s+#{RE_ITEM}#{RE_SZ_REF})*)
            \s+(?<m>#{RE_ITEM})#{RE_IX_00}
            (\s*\.+\s*|\k<m>#{RE_IX})*
            \k<m>#{RE_SZ}
            \z
          /x,
          ->(m) { m[:vs].split.map { |w| w.scan(RE_ITEM)[0] } + [m[:m]] },
          lambda { |vs|
            pat2 = vs[0..-2].map { |v| v + RE_IX.source }.join('\s+')
            m = vs[-1]
            /
              \A
              #{pat2}
              \s+#{m}#{RE_IX}
              (\s*\.+\s*|#{m}#{RE_IX})*
              (\s*\.+\s*|#{m}#{RE_SZ})
              \z
            /x
          }
        ),
        InputFormatMatcher.new(
          :varray, :number,
          /
            \A
            #{RE_ITEM}#{RE_SZ_0} (\s+#{RE_ITEM}#{RE_SZ_REF})*
            \z
          /x,
          ->(m) { m[0].split.map { |w| w.scan(RE_ITEM)[0] } },
          lambda { |vs|
            pat2 = vs.map.with_index do |v, i|
              v + (i.zero? ? RE_SZ : RE_IX).source
            end
            .join('\s+')
            /\A#{pat2}\z/
          }
        ),
        InputFormatMatcher.new(
          :single, :number,
          /\A(.*\s)?#{RE_SINGLE}(\s.*)?\z/,
          ->(m) { m[0].split.select { |w| w =~ /\A#{RE_SINGLE}\z/ } },
          nil
        )
      ].freeze
    end

    # parses input data format and generates input definitons
    module InputFormat
      include InputFormatConstants

      module_function

      def process(pbm)
        return unless (str = find_fmt(pbm))

        inpdefs = parse(str, pbm.samples)
        pbm.formats_raw = inpdefs
      end

      def find_fmt(pbm)
        str = nil
        SECTIONS.any? do |key|
          str = pbm.sections[key]&.code_block_html
          str && !str.empty?
        end
        str
      end

      def parse(str, smps)
        lines = normalize_fmt(str)
        inpdefs = parse_fmt(lines)
        normalize_defs!(inpdefs)
        smpx = max_smp(smps)
        smpx && match_smp!(inpdefs, smpx)
        inpdefs
      end

      def normalize_fmt(fmt)
        # 1) &npsp; , fill-width space -> half width space
        # 2) {i, j}->{i,j} for nested {}
        fmt
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
          .gsub(%r{[-/:](#{RE_SINGLE})}, ' \1') # a-b, a/b, a:b -> a b
          .gsub(/^\s*[.:][\s.:]*$/, '..')
          .tr('()', '{}')
          .gsub(/#{RE_BLOCK}/) { |w| w.delete(' ') } # 2)
          .split("\n")
          .map(&:strip)
      end

      def parse_fmt(lines)
        matcher = nil
        (lines + ['']).each_with_object([]) do |line, ret|
          if matcher
            next if matcher.match2(line)

            ret.last.size = matcher.size
          end
          if (matcher = MATCHERS.find { |m| m.match(line) })
            ret << Problem::InputFormat.new(
              matcher.container, matcher.item, matcher.names, ''
            )
          elsif !line.empty?
            puts "unknown format: #{line}"
            ret << Problem::InputFormat.new(:unknown, line)
          end
        end
      end

      def normalize_defs!(inpdefs)
        inpdefs.each do |inpdef|
          inpdef.names = normalize_names(inpdef.names)
          inpdef.size = normalize_size(inpdef.container, inpdef.size)
        end
      end

      def normalize_names(names)
        return names unless names.is_a?(Array)

        names.map { |nm| nm.delete('{}').gsub(/(\A_+|_+\z)/, '') }
      end

      def normalize_size(container, size)
        sz =
          case container
          when :matrix, :vmatrix
            split_size(size)
          when :harray, :varray
            [size]
          when :single
            []
          end
        sz&.map do |w|
          w
            .delete('{},')
            .gsub(/(\A_+|(_|-1)+\z)/, '') # extra underscores, N-1 -> N
        end
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

      def max_smp(smps)
        smps
          .select { |smp| smp.ext == :in }
          .max_by { |smp| smp.txt.size }
          &.txt
      end

      def match_smp!(inpdefs, smp)
        lines = smp.split("\n")
        inpdefs.each_with_index do |inpdef, i|
          break if i >= lines.size
          next if inpdef.item != :number

          inpdef.item = :string if lines[i].split[0] =~ /[^\-0-9]/
          break if %i[varray vmatrix matrix].include?(inpdef.container)
        end
        inpdefs
      end
    end
  end
end
