# frozen_string_literal: true

require 'mechanize'
require 'logger'

module AtCoderFriends
  module Scraping
    # common functions for scraping
    class Agent
      include AtCoderFriends::PathUtil
      include Session
      include Authentication
      include Tasks
      include CustomTest
      include Submission

      BASE_URL = 'https://atcoder.jp/'

      attr_reader :ctx, :agent

      def initialize(ctx)
        @ctx = ctx
        @agent = Mechanize.new
        agent.pre_connect_hooks << proc { sleep 0.1 }
        agent.log = Logger.new(STDERR) if ctx.options[:debug]
        load_session
      end

      def contest
        @contest ||= contest_name(ctx.path)
      end

      def common_url(path)
        File.join(BASE_URL, path)
      end

      def contest_url(path = '')
        File.join(BASE_URL, 'contests', contest, path)
      end

      def lang_id(ext)
        ctx.config.dig('ext_settings', ext, 'submit_lang') || (
          msg = <<~MSG
            submit_lang for .#{ext} is not specified.
            Available languages:
            #{lang_list_txt || '(failed to fetch)'}
          MSG
          raise AppError, msg
        )
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
