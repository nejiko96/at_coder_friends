# frozen_string_literal: true

module AtCoderFriends
  module Scraping
    # submit sources on submit page
    module Submission
      def submit
        path, _dir, prg, _base, ext, q = ctx.path_info.components
        puts "***** submit #{prg} *****"
        lang = lang_id(ext)
        src = File.read(path, encoding: Encoding::UTF_8)

        post_submit(q, lang, src)
      end

      def post_submit(q, lang, src)
        page = fetch_with_auth(contest_url('submit'))
        form = page.forms[1]
        form.field_with(name: 'data.TaskScreenName') do |sel|
          option = sel.options.find { |op| op.text.start_with?(q) }
          option&.select || (raise AppError, "unknown problem:#{q}.")
        end
        form.add_field!('data.LanguageId', lang)
        form.field_with(name: 'sourceCode').value = src
        form.submit
      end
    end
  end
end
