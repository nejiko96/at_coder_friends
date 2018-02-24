# frozen_string_literal: true

module AtCoderFriends
  # Iterates through elements of an array
  class Iterator
    def initialize(array)
      @array = array
      @i = 0
    end

    def next?
      @i < @array.size
    end

    def next
      ret = @array[@i]
      @i += 1
      ret
    end
  end

  # parses input data format and generates input definitons
  class FormatParser
    PARSERS = [
      {
        container: :harray,
        item: :number,
        pat: /^(?<v>[a-z]+)[01](\s+\k<v>.)*(\s+\.+)?(\s+\k<v>.)+$/i,
        names: ->(m) { [m[:v]] },
        pat2: ->(_) { nil },
        size: ->(f) { [f[-1]] }
      },
      {
        container: :harray,
        item: :char,
        pat: /^(?<v>[a-z]+)[01](\k<v>.)*(\s*\.+\s*)?(\k<v>.)+$/i,
        names: ->(m) { [m[:v]] },
        pat2: ->(_) { nil },
        size: ->(f) { [f[-1]] }
      },
      {
        container: :matrix,
        item: :number,
        pat: /^(?<v>[a-z]+)[01][01](\s+\k<v>..)*(\s+\.+)?(\s+\k<v>..)+$/i,
        names: ->(m) { [m[:v]] },
        pat2: ->(v) { /(^#{v}..(\s+#{v}..)*(\s+\.+)?(\s+#{v}..)+|\.+)$/ },
        size: ->(f) { f[-2..-1].chars.to_a }
      },
      {
        container: :matrix,
        item: :char,
        pat: /^(?<v>[a-z]+)[01][01](\k<v>..)*(\s*\.+\s*)?(\k<v>..)+$/i,
        names: ->(m) { [m[:v]] },
        pat2: ->(v) { /(^#{v}..(#{v}..)*(\s*\.+\s*)?(#{v}..)+|\.+)$/ },
        size: ->(f) { f[-2..-1].chars.to_a }
      },
      {
        container: :varray,
        item: :number,
        pat: /^[a-z]+(?<i>[0-9])(\s+[a-z]+\k<i>)*$/i,
        names: ->(m) { m[0].split.map { |w| w[0..-2] } },
        pat2: lambda { |vs|
          pat = vs.map { |v| v + '.+' }.join('\s+')
          /^(#{pat}|\.+)$/
        },
        size: ->(f) { /(?<sz>\d+)$/ =~ f ? [sz] : [f[-1]] }
      },
      {
        container: :single,
        item: :number,
        pat: /^[a-z]+(\s+[a-z]+)*$/i,
        names: ->(m) { m[0].split },
        pat2: ->(_) { nil },
        size: ->(_) { [] }
      }
    ].freeze

    def process(pbm)
      defs = parse(pbm.fmt, pbm.smps)
      pbm.defs = defs
    end

    def parse(fmt, smps)
      lines = split_trim(fmt)
      defs = parse_fmt(lines)
      smpx = max_smp(smps)
      return defs unless smpx
      match_smp!(defs, smpx)
    end

    def split_trim(fmt)
      fmt
        .gsub(/[+-]1/, '') # N-1, N+1 -> N
        .gsub(%r{[-/　]}, ' ') # a-b, a/b -> a b
        .gsub(/\{.*?\}/) { |w| w.delete(' ') } # {1, 1} -> {1,1} shortest match
        .gsub(/[_,\\\(\)\{\}]/, '')
        .gsub(/[:：…‥]+/, '..')
        .gsub(/^[\.\s]+$/, '..')
        .split("\n")
        .map(&:strip)
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def parse_fmt(lines)
      it = Iterator.new(lines + ['']) # sentinel
      prv = nil
      cur = it.next
      Enumerator.new do |y|
        loop do
          unless (parser = PARSERS.find { |ps| ps[:pat] =~ cur })
            puts "unknown format: #{cur}" unless cur.empty?
            (cur = it.next) ? next : break
          end
          container, item = parser.values_at(:container, :item)
          m = parser[:pat].match(cur)
          names = parser[:names].call(m)
          pat2 = parser[:pat2].call(names)
          loop do
            prv = cur
            cur = it.next
            break unless pat2 && pat2 =~ cur
          end
          size = parser[:size].call(prv)
          y << InputDef.new(container, item, names, size)
        end
      end.to_a
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def max_smp(smps)
      smps
        .select { |smp| smp.ext == :in }
        .max_by { |smp| smp.txt.size }
        &.txt
    end

    def match_smp!(inpdefs, smp)
      lines = smp.split("\n")
      inpdefs.each_with_index do |inpdef, i|
        break if i > lines.size
        next if inpdef.item != :number
        inpdef.item = :string if lines[i].split[0] =~ /[^\-0-9]/
        break if %i[varray matrix].include?(inpdef.container)
      end
      inpdefs
    end
  end
end
