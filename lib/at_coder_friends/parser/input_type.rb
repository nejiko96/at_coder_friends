# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # parses input data types and updates input definitons
    module InputType
      module_function

      NUMBER_PAT = /\A[+-]?[0-9]+\z/.freeze
      TYPE_TBL = [
        [:number, NUMBER_PAT],
        [:decimal, /\A[+-]?[0-9]+(\.[0-9]+)?\z/]
      ].freeze

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
        vars = {}
        inpdefs.each do |inpdef|
          break unless  (k = get_line_cnt(inpdef))

          k, parsed = parse_line_cnt(k, vars)
          rows = lines.shift(k).map { |line| line.split(/[#{inpdef.delim} ]/) }
          break if rows.empty?

          inpdef.container == :single &&
            vars.merge!(inpdef.names.zip(rows[0]).to_h)
          inpdef.cols = detect_cols_type(rows)
          break unless parsed
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

      def parse_line_cnt(k, vars)
        if k.is_a?(Integer)
          [k, true]
        elsif k =~ NUMBER_PAT
          [k.to_i, true]
        elsif vars[k] =~ NUMBER_PAT
          [vars[k].to_i, true]
        else
          [1, false]
        end
      end

      def detect_cols_type(rows)
        cols = fill_transpose(rows).map(&:compact)
        cols.map { |col| detect_col_type(col) }
      end

      def fill_transpose(arr)
        Array.new(arr.map(&:size).max) { |i| arr.map { |e| e[i] } }
      end

      def detect_col_type(arr)
        ret = :string
        TYPE_TBL.any? do |type, pat|
          arr.all? { |v| v =~ pat } && ret = type
        end
        ret
      end
    end
  end
end
