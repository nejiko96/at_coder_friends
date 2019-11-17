# frozen_string_literal: true

module AtCoderFriends
  module Parser
    InputFormatMatcher = Struct.new(:container, :item, :pat, :gen_names, :gen_pat2) do
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
      ITEM_PAT = /\{*[A-Za-z]+(?:_[A-Za-z]+)*\}*/.freeze
      SZ = '(_(?<sz>\S+)|{(?<sz>\S+)})'
      SINGLE_PAT = /([A-Za-z{][A-Za-z_0-9{}]*)/.freeze
      MATCHERS = [
        InputFormatMatcher.new(
          :matrix, :number,
          /
            \A
            (?<v>#{ITEM_PAT})[_{]\{*[01][,_]?[01]\}*
            (\s+\k<v>[_{]\S+)*
            (\s+\.+)?
            (\s+\k<v>#{SZ})+
            \z
          /x,
          ->(m) { [m[:v]] },
          lambda { |((v))|
            /
              \A
              #{v}[_{]\S+
              (\s+#{v}#{SZ})*
              (\s+\.+)?
              (\s+#{v}#{SZ})*
              \z
            /x
          }
        ),
        InputFormatMatcher.new(
          :matrix, :char,
          /
            \A
            (?<v>#{ITEM_PAT})[_{]\{*[01][,_]?[01]\}*
            (\k<v>[_{]\S+)*
            (\s*\.+\s*)?
            (\k<v>#{SZ})+
            \z
          /x,
          ->(m) { [m[:v]] },
          lambda { |((v))|
            /
              \A
              (#{v}[_{]\S+)+
              (\s*\.+\s*)?
              (#{v}#{SZ})+
              \z
            /x
          }
        ),
        InputFormatMatcher.new(
          :harray, :number,
          /
            \A
            (?<v>#{ITEM_PAT})[_{]\{*[0-9]\}*
            (\s+\k<v>[_{]\S+)*
            (\s+\.+)?
            (\s+\k<v>#{SZ})+
            \z
          /x,
          ->(m) { [m[:v]] },
          nil
        ),
        InputFormatMatcher.new(
          :harray, :char,
          /
            \A
            (?<v>#{ITEM_PAT})[_{]\{*[0-9]\}*
            (\k<v>[_{]\S+)*
            (\s*\.+\s*)?
            (\k<v>#{SZ})+
            \z
          /x,
          ->(m) { [m[:v]] },
          nil
        ),
        InputFormatMatcher.new(
          :varray, :number,
          /
            \A
            #{ITEM_PAT}[_{]\{*(?<sz>[0-9]+)\}*
            (\s+#{ITEM_PAT}[_{]\{*\k<sz>\}*)*
            \z
          /x,
          ->(m) { m[0].split.map { |w| w.scan(ITEM_PAT)[0] } },
          lambda { |vs|
            pat2 = vs.map { |v| v + SZ }.join('\s+')
            /\A#{pat2}\z/
          }
        ),
        InputFormatMatcher.new(
          :single, :number,
          /\A(.*\s)?#{SINGLE_PAT}(\s.*)?\z/,
          ->(m) { m[0].split.select { |w| w =~ /\A#{SINGLE_PAT}\z/ } },
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
        pbm.formats = inpdefs
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
          .gsub('−', '-') # fill width hyphen
          .gsub(/[・：‥⋮︙…]+/, '..')
          .gsub(/[\\$']/, '') # s' -> s
          .gsub(/[&~|]/, ' ') # |S| -> S
          .gsub(%r{[-/:](#{SINGLE_PAT})}, ' \1') # a-b, a/b, a:b -> a b
          .gsub(/^\s*[.:][\s.:]*$/, '..')
          .tr('()', '{}')
          .gsub(/(?<bl>\{(?:[^{}]|\g<bl>)*\})/) { |w| w.delete(' ') } # 2)
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
            # ret << Problem::InputFormat.new(:unknown, nil, line)
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
          when :matrix
            matrix_size(size)
          when :harray, :varray
            [size]
          else
            []
          end
        sz.map do |w|
          w
            .delete('{},')
            .gsub(/(\A_+|(_|-1)+\z)/, '') # extra underscores, N-1 -> N
        end
      end

      def matrix_size(str)
        sz = str.scan(/([^{}]+|\{[^{}]+\}})/).flatten
        return sz if sz.size == 2

        sz = str.split(',')
        return sz if sz.size == 2

        sz = str.split('_')
        return sz if sz.size == 2

        str = str.delete('{},')
        len = str.size
        if len.positive? && len.even?
          return str.chars.each_slice(len / 2).map(&:join)
        end

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
          break if %i[varray matrix].include?(inpdef.container)
        end
        inpdefs
      end
    end
  end
end
