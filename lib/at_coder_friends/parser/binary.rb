# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # detect binary problem
    module Binary
      module_function

      def process(pbm)
        vs = exp_values(pbm)
        return unless vs.size == 2
        return if vs.any? { |v| v.include?("\n") }
        return if vs.any? { |v| v =~ /^[0-9\s]*$/ }

        out_fmt = ouput_format(pbm)
        re1, re2 = vs.map { |v| Regexp.escape(v) }

        pbm.options.binary_values =
          if out_fmt =~ /#{re1}.+#{re2}/m
            vs
          elsif out_fmt =~ /#{re2}.+#{re1}/m
            vs.reverse
          end
      end

      def exp_values(pbm)
        pbm
          .samples
          .select { |smp| smp.ext == :exp }
          .map { |smp| smp.txt.chomp }
          .uniq
      end

      def ouput_format(pbm)
        pbm.sections[Problem::SECTION_OUT_FMT]&.content || ''
      end
    end
  end
end
