# frozen_string_literal: true

require 'English'

module AtCoderFriends
  module Parser
    # parses sample data and sets to problem
    module SampleData
      module_function

      def process(pbm)
        pbm.sections.each do |key, section|
          ext =
            if key =~ Problem::SECTION_IN_SMP_PAT
              :in
            elsif key =~ Problem::SECTION_OUT_SMP_PAT
              :exp
            end
          ext && pbm.add_smp($LAST_MATCH_INFO[:no], ext, section.code_block)
        end
      end
    end
  end
end
