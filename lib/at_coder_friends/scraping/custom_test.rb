# frozen_string_literal: true

require 'json'

module AtCoderFriends
  module Scraping
    # run tests on custom_test page
    module CustomTest
      def code_test(infile)
        path, _dir, _prg, _base, ext, _q = ctx.path_info.components
        lang = lang_id(ext)
        src = File.read(path, encoding: Encoding::UTF_8)
        data = File.read(infile)

        post_custom_test(lang, src, data)
        check_custom_test
      end

      def post_custom_test(lang, src, data)
        page = fetch_with_auth(contest_url('custom_test'))
        script = page.search('script').text
        csrf_token = script.scan(/var csrfToken = "(.*)"/)[0][0]

        page = agent.post(
          contest_url('custom_test/submit/json'),
          'data.LanguageId' => lang,
          'sourceCode' => src,
          'input' => data,
          'csrf_token' => csrf_token
        )

        msg = page.body
        raise AppError, msg unless msg.empty?
      end

      def check_custom_test
        100.times do
          page = agent.get(contest_url('custom_test/json?reload=true'))
          data = JSON.parse(page.body)
          return nil unless data.is_a?(Hash) && data['Result']
          return data if data.dig('Result', 'Status') == 3
          return data unless data['Interval']

          sleep 1.0 * data['Interval'] / 1000
        end

        nil
      end
    end
  end
end
