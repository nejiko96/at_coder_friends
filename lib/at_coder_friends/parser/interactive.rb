# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # detect interactive problem
    module Interactive
      module_function

      INTERACTIVE_PAT = '(インタラクティブ|interactive|リアクティブ|reactive)'
      FLUSH_PAT = 'flush'

      def process(pbm)
        pbm.options.interactive = false

        body = pbm.page_body
        f_int = body.match(/#{INTERACTIVE_PAT}/i)
        f_flush = body.match(/#{FLUSH_PAT}/i)
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
