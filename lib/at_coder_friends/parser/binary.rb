# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # detect binary problem
    module Binary
      module_function

      def process(pbm)
        vs = exp_values(pbm)
        return unless binary_values?(vs)

        out_fmt = output_format(pbm)
        re1, re2 = vs.map { |v| Regexp.escape(v) }

        pbm.options.binary_values =
          case out_fmt
          when /#{re1}.+#{re2}/m
            vs
          when /#{re2}.+#{re1}/m
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

      def binary_values?(vs)
        return false unless vs.size == 2
        return false if vs.any? { |v| v.include?("\n") }
        return false if vs.any? { |v| v =~ /\A[0-9\s]*\z/ }

        true
      end

      def output_format(pbm)
        pbm.sections[Problem::SECTION_OUT_FMT]&.content || ''
      end
    end
  end
end
