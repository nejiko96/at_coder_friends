# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # detect interactive problem
    module Interactive
      module_function

      INTERACTIVE_PAT = /
        インタラクティブ
        |interactive
        |リアクティブ
        |reactive
      /xi.freeze
      FLUSH_PAT = /flush/i.freeze

      def process(pbm)
        pbm.options.interactive = false

        body = pbm.body_content
        f_int = body =~ INTERACTIVE_PAT
        f_flush = body =~ FLUSH_PAT
        f_io = pbm.sections[Problem::SECTION_IO_FMT]
        f_tbl =
          pbm
          .sections[Problem::SECTION_IO_SMP]
          &.find_element(%w[table])
        return unless [f_int, f_flush, f_io, f_tbl].count(&:itself) > 1

        pbm.options.interactive = true
      end
    end
  end
end
