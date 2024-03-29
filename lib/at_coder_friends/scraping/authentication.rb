# frozen_string_literal: true

require 'cgi'
require 'io/console'

module AtCoderFriends
  module Scraping
    # fetch pages and
    # authenticates user at login page if needed
    module Authentication
      XPATH_USERNAME = '//*[@id="navbar-collapse"]/ul[2]/li[2]/a'

      def fetch_with_auth(url)
        page = fetch_raw(url)
        page.uri.path == '/login' && page = post_login(page)
        page.uri.path == '/login' && (raise AppError, 'Authentication failed.')
        show_username(page)
        page
      end

      def fetch_raw(url)
        begin
          return agent.get(url)
        rescue Mechanize::ResponseCodeError => e
          raise e if username_link(e.page)
        end

        agent.get("#{common_url('login')}?continue=#{CGI.escape(url)}")
      end

      def post_login(page)
        user, pass = read_auth
        form = page.forms[1]
        form.field_with(name: 'username').value = user
        form.field_with(name: 'password').value = pass
        form.submit
      end

      def read_auth
        user = ctx.config['user'].to_s
        if user.empty?
          print('enter username:')
          user = $stdin.gets.chomp
        end

        pass = ctx.config['password'].to_s
        if pass.empty?
          print("enter password for #{user}:")
          pass = $stdin.noecho(&:gets).chomp
          puts
        end
        [user, pass]
      end

      def show_username(page)
        username_bak = @username
        link = username_link(page)
        @username = (link ? link.text.strip : '-')
        return if @username == username_bak || @username == '-'

        puts "logged in as #{@username}"
      end

      def username_link(page)
        link = page.search(XPATH_USERNAME)[0]
        link && link[:href] == '#' && link
      end
    end
  end
end
