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
        smpx = max_smp(smps)
        smpx && match_smp(inpdefs, smpx)
      end

      def max_smp(smps)
        smps
          .select { |smp| smp.ext == :in }
          .max_by { |smp| smp.txt.size }
          &.txt
      end

      def match_smp(inpdefs, smp)
        lines = smp.split("\n")
        inpdefs.each_with_index do |inpdef, i|
          break if i >= lines.size
          next if inpdef.item != :number

          inpdef.item = :string if lines[i] =~ /[^\-0-9 ]/
          break unless %i[single harray].include?(inpdef.container)
        end
        inpdefs
      end
    end
  end
end
