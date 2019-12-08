# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # parses input data types and updates input definitons
    module InputType
      module_function

      def process(pbm)
        parse(pbm.formats_src, pbm.samples)
      end

      def parse(inpdefs, smps)
        lines = max_smp(smps)&.split("\n")
        lines && match_smp(inpdefs, lines)
      end

      def max_smp(smps)
        smps
          .select { |smp| smp.ext == :in }
          .max_by { |smp| smp.txt.size }
          &.txt
      end

      def match_smp(inpdefs, lines)
        singles = {}
        inpdefs.each do |inpdef|
          break unless  (k = get_line_cnt(inpdef))

          k, ctn = parse_line_cnt(k, singles)
          dat = lines.shift(k).join("\n").gsub(/[#{inpdef.delim} ]/, ' ')
          inpdef.item == :number &&
            dat =~ /[^-+0-9\s]/ &&
            inpdef.item = :string
          inpdef.container == :single &&
            singles = singles.merge(inpdef.names.zip(dat.split).to_h)
          break unless ctn
        end
        inpdefs
      end

      def get_line_cnt(inpdef)
        case inpdef.size&.size
        when 0
          1
        when 1
          inpdef.container == :harray ? 1 : inpdef.size[0]
        when 2
          inpdef.size[0]
        end
      end

      def parse_line_cnt(k, singles)
        if k.is_a?(Integer)
          [k, true]
        elsif k =~ /\A[+-]?[0-9]+\z/
          [k.to_i, true]
        elsif singles[k] =~ /\A[+-]?[0-9]+\z/
          [singles[k].to_i, true]
        else
          [1, false]
        end
      end
    end
  end
end
