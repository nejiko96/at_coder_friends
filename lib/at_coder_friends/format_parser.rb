# frozen_string_literal: true

module AtCoderFriends
  class FormatParser
    def parse(pbm)
      defs = parse_fmt(pbm.fmt)
      smpx = pbm
             .smps
             .select { |smp| smp.ext == :in }
             .max_by { |smp| smp.txt.size }
      match_type(defs, smpx)
      pbm.defs = defs
    end

    def parse_fmt(fmt)
      inpdefs = []
      fmt = fmt
            .gsub(/-1/, '') # N-1 -> N
            .gsub(%r{(-|/|　)}, ' ') # a-b -> a b
            .gsub(/\{.+?\}/) { |w| w.delete(' ') } # {1, 1} -> {1,1}
            .gsub(/[_,\\\(\)\{\}]/, '')
            .split("\n")
            .map(&:strip)
      fmt << ''
      re = prev = nil
      fmt.each do |f|
        if re
          if f =~ re
            prev = f
            next
          end
          inpdef = inpdefs.last
          case inpdef.type
          when :matrix
            inpdef.size = prev[-2..-1].chars.to_a
          when :varray
            inpdef.size = prev =~ /(?<sz>\d+)$/ ? sz : prev[-1]
          end
          re = prev = nil
        end
        case f
        when /^(?<v>[a-z]+).(\s+\k<v>.)*\s*[\.…‥]+\s*\k<v>.$/i,
             /^(?<v>[a-z]+)[01](\s+\k<v>.)+$/i
          inpdefs << InputDef.new(:harray, f[-1], :number, v)
        when /^(?<v>[a-z]+).(\k<v>.)*\s*[\.…‥]+\s*\k<v>.$/i,
             /^(?<v>[a-z]+)[01](\k<v>.)+$/i
          inpdefs << InputDef.new(:harray, f[-1], :char, v)
        when /^(?<v>[a-z]+)..(\s+\k<v>..)*\s+[\.…‥]+\s+\k<v>..$/i
          inpdefs << InputDef.new(:matrix, nil, :number, v)
          re = /(^#{v}..(\s+#{v}..)*\s+[\.…‥]+\s+#{v}..|[:：…‥]|\.+)$/
          prev = f
        when /^(?<v>[a-z]+)..(\k<v>..)*\s*[\.…‥]+(\s*\k<v>..)+$/i
          inpdefs << InputDef.new(:matrix, nil, :char, v)
          re = /(^#{v}..(#{v}..)*\s*[\.…‥]+(\s*#{v}..)+|[:：…‥]|\.+)$/
          prev = f
        when /^(?<v>[a-z]+)[01][01](\s+\k<v>..)+$/i
          inpdefs << InputDef.new(:matrix, nil, :number, v)
          re = /(^#{v}..(\s+#{v}..)+|[:：…‥]|\.+)$/
          prev = f
        when /^[a-z]+(?<i>\d)(\s+[a-z]+\k<i>)*$/i
          vars = f.split.map { |v| v[0..-2] }
          inpdefs << InputDef.new(:varray, nil, :number, vars)
          pat = vars.map { |v| v + '.+' }.join('\s+')
          re = /^(#{pat}|[:：…‥]|\.+)$/
          prev = f
        when /^[a-z]+(\s+[a-z]+)*$/i
          inpdefs << InputDef.new(:single, nil, :number, f.split)
        end
      end
      inpdefs
    end

    def match_type(inpdefs, smp)
      return if smp.nil?
      lines = smp.txt.split("\n")
      inpdefs.each_with_index do |inpdef, i|
        next if inpdef.fmt != :number
        inpdef.fmt = :string if lines[i].split[0] =~ /[^\-0-9]/
        break if %i[varray matrix].include?(inpdef.type)
      end
    end
  end
end
