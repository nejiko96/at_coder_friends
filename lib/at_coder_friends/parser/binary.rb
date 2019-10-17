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
        return if vs.any? { |v| v.match(/^[0-9\s]*$/) }

        out_fmt = ouput_format(pbm)
        re1, re2 = vs.map { |v| Regexp.escape(v) }
        return unless out_fmt.match(/(#{re1}.+#{re2}|#{re2}.+#{re1})/m)

        vs.reverse! unless out_fmt.match(/#{re1}.+#{re2}/m)
        pbm.options.binary_values = vs
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
