# frozen_string_literal: true

module AtCoderFriends
  module Scraping
    # session management for scraping
    module Session
      SESSION_STORE_FMT = File.join(
        Dir.home, '.at_coder_friends', '%<user>s_session.yml'
      )

      def load_session
        agent.cookie_jar.load(session_store) if File.exist?(session_store)
      end

      def save_session
        dir = File.dirname(session_store)
        Dir.mkdir(dir) unless Dir.exist?(dir)
        agent.cookie_jar.save_as(session_store)
      end

      def session_store
        @session_store ||= format(SESSION_STORE_FMT, user: config['user'])
      end
    end
  end
end
