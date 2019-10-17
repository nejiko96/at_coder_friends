# frozen_string_literal: true

require 'English'

module AtCoderFriends
  module Parser
    # parses sample data and sets to problem
    module SampleData
      module_function

      def process(pbm)
        pbm.sections.each do |key, section|
          if key =~ Problem::SECTION_IN_SMP_PAT
            pbm.add_smp($LAST_MATCH_INFO[:no], :in, section.code_block)
          elsif key =~ Problem::SECTION_OUT_SMP_PAT
            pbm.add_smp($LAST_MATCH_INFO[:no], :exp, section.code_block)
          end
        end
      end
    end
  end
end
