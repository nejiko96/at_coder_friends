# frozen_string_literal: true

module AtCoderFriends
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

  class FormatParser
    PARSERS = [
      {
        type: :harray,
        fmt: :number,
        pat: /^(?<v>[a-z]+)[01](\s+\k<v>.)*(\s+\.+)?(\s+\k<v>.)+$/i,
        vars: ->(m) { m[:v] },
        pat2: ->(_) { nil },
        size: ->(f) { f[-1] }
      },
      {
        type: :harray,
        fmt: :char,
        pat: /^(?<v>[a-z]+)[01](\k<v>.)*(\s*\.+\s*)?(\k<v>.)+$/i,
        vars: ->(m) { m[:v] },
        pat2: ->(_) { nil },
        size: ->(f) { f[-1] }
      },
      {
        type: :matrix,
        fmt: :number,
        pat: /^(?<v>[a-z]+)[01][01](\s+\k<v>..)*(\s+\.+)?(\s+\k<v>..)+$/i,
        vars: ->(m) { m[:v] },
        pat2: ->(v) { /(^#{v}..(\s+#{v}..)*(\s+\.+)?(\s+#{v}..)+|\.+)$/ },
        size: ->(f) { f[-2..-1].chars.to_a }
      },
      {
        type: :matrix,
        fmt: :char,
        pat: /^(?<v>[a-z]+)[01][01](\k<v>..)*(\s*\.+\s*)?(\k<v>..)+$/i,
        vars: ->(m) { m[:v] },
        pat2: ->(v) { /(^#{v}..(#{v}..)*(\s*\.+\s*)?(#{v}..)+|\.+)$/ },
        size: ->(f) { f[-2..-1].chars.to_a }
      },
      {
        type: :varray,
        fmt: :number,
        pat: /^[a-z]+(?<i>[01])(\s+[a-z]+\k<i>)*$/i,
        vars: ->(m) { m[0].split.map { |w| w[0..-2] } },
        pat2: lambda { |vs|
          pat = vs.map { |v| v + '.+' }.join('\s+')
          /^(#{pat}|\.+)$/
        },
        size: ->(f) { /(?<sz>\d+)$/ =~ f ? sz : f[-1] }
      },
      {
        type: :single,
        fmt: :number,
        pat: /^[a-z]+(\s+[a-z]+)*$/i,
        vars: ->(m) { m[0].split },
        pat2: ->(_) { nil },
        size: ->(_) { '' }
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
      return unless smpx
      match_smp!(defs, smpx)
    end

    def split_trim(fmt)
      fmt
        .gsub(/-1/, '') # N-1 -> N
        .gsub(%r{(-|/|　)}, ' ') # a-b -> a b
        .gsub(/\{.+?\}/) { |w| w.delete(' ') } # {1, 1} -> {1,1}
        .gsub(/[_,\\\(\)\{\}]/, '')
        .gsub(/[:：…‥]/, '...')
        .split("\n")
        .map(&:strip)
    end

    def parse_fmt(lines)
      it = Iterator.new(lines + ['']) # sentinel
      prv = nil
      cur = it.next
      Enumerator.new do |y|
        loop do
          parser = PARSERS.find { |ps| ps[:pat] =~ cur }
          unless parser
            break unless it.next?
            cur = it.next
            next
          end
          type, fmt = parser.values_at(:type, :fmt)
          m = parser[:pat].match(cur)
          vars = parser[:vars].call(m)
          pat2 = parser[:pat2].call(vars)
          loop do
            prv = cur
            cur = it.next
            break unless pat2 && pat2 =~ cur
          end
          size = parser[:size].call(prv)
          y << InputDef.new(type, size, fmt, vars)
        end
      end.to_a
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
        break if i > lines.size
        next if inpdef.fmt != :number
        inpdef.fmt = :string if lines[i].split[0] =~ /[^\-0-9]/
        break if %i[varray matrix].include?(inpdef.type)
      end
      inpdefs
    end
  end
end
