# frozen_string_literal: true

require 'mechanize'
require 'logger'

module AtCoderFriends
  module Scraping
    # common functions for scraping
    class Agent
      include Session
      include Authentication
      include Tasks
      include CustomTest
      include Submission

      BASE_URL = 'https://atcoder.jp/'
      CONTACT = 'https://github.com/nejiko96/at_coder_friends'

      attr_reader :ctx, :agent

      def initialize(ctx)
        @ctx = ctx
        @agent = Mechanize.new
        agent.user_agent = "AtCoderFriends/#{VERSION} (#{CONTACT})"
        agent.pre_connect_hooks << proc { sleep 0.1 }
        agent.log = Logger.new($stderr) if ctx.options[:debug]
        load_session
      end

      def contest
        @contest ||= ctx.path_info.contest_name
      end

      def common_url(path)
        File.join(BASE_URL, path)
      end

      def contest_url(path = '')
        File.join(BASE_URL, 'contests', contest, path)
      end

      def lang_id(ext)
        [lang_id_conf(ext)].flatten
      end

      def lang_id_conf(ext)
        ctx.config.dig('ext_settings', ext, 'submit_lang') || (
          msg = <<~MSG
            submit_lang for .#{ext} is not specified.
            Available languages:
            #{lang_list_txt || '(failed to fetch)'}
          MSG
          raise AppError, msg
        )
      end

      def find_lang(page, langs)
        langs.find do |lng|
          page.search("div#select-lang select option[value=#{lng}]")[0]
        end || langs[0]
      end

      def lang_list_txt
        lang_list
          &.map { |opt| "#{opt[:v]} - #{opt[:t]}" }
          &.join("\n")
      end

      def lang_list
        @lang_list ||= begin
          page = fetch_with_auth(contest_url('custom_test'))
          form = page.forms[1]
          sel = form.field_with(name: 'data.LanguageId')
          sel && sel
            .options
            .reject { |opt| opt.value.empty? }
            .map do |opt|
              { v: opt.value, t: opt.text }
            end
        end
      end
    end
  end
end
