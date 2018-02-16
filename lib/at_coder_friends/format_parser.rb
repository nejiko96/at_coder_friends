# frozen_string_literal: true

require 'English'

module AtCoderFriends
  class FormatParser

    def process(pbm)
      defs = parse(pbm.fmt, pbm.smps)
      pbm.defs = defs
    end

    def parse(fmt, smps)
      defs = parse_fmt(fmt)
      smpx = smps
             .select { |smp| smp.ext == :in }
             .max_by { |smp| smp.txt.size }
             &.txt
      return unless smpx
      match_smp(defs, smpx)
    end

    def parse_fmt(fmt)
      lines = split_trim(fmt)
      lines << ''
      inpdefs = []
      re = prev = nil
      lines.each do |f|
        if re
          if re =~ f
            prev = f
            next
          end
          inpdef = inpdefs.last
          case inpdef.type
          when :matrix
            inpdef.size = prev[-2..-1].chars.to_a
          when :varray
            inpdef.size = /(?<sz>\d+)$/ =~ prev ? sz : prev[-1]
          end
          re = prev = nil
        end
        case f
        when /^(?<v>[a-z]+)[01](\s+\k<v>.)*(\s+\.+)?(\s+\k<v>.)+$/i
          v = $LAST_MATCH_INFO[:v]
          inpdefs << InputDef.new(:harray, f[-1], :number, v)
        when /^(?<v>[a-z]+)[01](\k<v>.)*(\s*\.+\s*)?(\k<v>.)+$/i
          v = $LAST_MATCH_INFO[:v]
          inpdefs << InputDef.new(:harray, f[-1], :char, v)
        when /^(?<v>[a-z]+)[01][01](\s+\k<v>..)*(\s+\.+)?(\s+\k<v>..)+$/i
          v = $LAST_MATCH_INFO[:v]
          inpdefs << InputDef.new(:matrix, nil, :number, v)
          re = /(^#{v}..(\s+#{v}..)*(\s+\.+)?(\s+#{v}..)+|\.+)$/
          prev = f
        when /^(?<v>[a-z]+)[01][01](\k<v>..)*(\s*\.+\s*)?(\k<v>..)+$/i
          v = $LAST_MATCH_INFO[:v]
          inpdefs << InputDef.new(:matrix, nil, :char, v)
          re = /(^#{v}..(#{v}..)*(\s*\.+\s*)?(#{v}..)+|\.+)$/
          prev = f
        when /^[a-z]+(?<i>[01])(\s+[a-z]+\k<i>)*$/i
          vars = f.split.map { |w| w[0..-2] }
          inpdefs << InputDef.new(:varray, nil, :number, vars)
          pat = vars.map { |w| w + '.+' }.join('\s+')
          re = /^(#{pat}|\.+)$/
          prev = f
        when /^[a-z]+(\s+[a-z]+)*$/i
          inpdefs << InputDef.new(:single, nil, :number, f.split)
        end
      end
      inpdefs
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

    def match_smp(inpdefs, smp)
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
