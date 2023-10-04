# frozen_string_literal: true

module AtCoderFriends
  # miscellaneous tasks
  module Maintenance
    module_function

    URL_BASE = 'https://atcoder.jp/'
    ACF_HOME = File.expand_path(File.join(__dir__, '..', '..'))
    MOCK_BASE = File.join(ACF_HOME, 'spec', 'mocks')
    MOCK_PATHS = %w[
      /login
      /contests/abc003/tasks/abc003_4
      /contests/arc001/tasks
      /contests/arc001/tasks/arc001_1
      /contests/arc001/tasks/arc001_2
      /contests/arc001/tasks/arc001_3
      /contests/arc001/tasks/arc001_4
      /contests/arc002/tasks/arc002_1
      /contests/arc002/tasks/arc002_4
      /contests/kupc2014/tasks/kupc2014_l
      /contests/tdpc/tasks
      /contests/tdpc/tasks/tdpc_contest
      /contests/practice/tasks
      /contests/practice/tasks/practice_1
      /contests/practice/tasks/practice_2
      /contests/practice/custom_test
      /contests/practice/submit
    ].freeze
    CSRF_TOKEN = 'Z66S2ieHP1AC3P9JfCbHCzGdYA/JhAStb0KsQ0kOC0s='

    def update_mocks
      agent = Context.new({}, __FILE__).scraping_agent
      MOCK_PATHS.each do |path|
        url = File.join(URL_BASE, path)
        file = File.join(MOCK_BASE, "#{path}.html")
        puts "#{url} -> #{file}"
        page = (
          if path.include?('/practice')
            agent.fetch_with_auth(url)
          else
            agent.fetch_raw(url)
          end
        )
        body = page
          .body
          .gsub(
            %r!(name="csrf_token" value=|var csrfToken = )"([^"]+)"!,
            "\\1\"#{CSRF_TOKEN}\""
          )

        File.binwrite(file, body)
      end
    end
  end
end

namespace :mainte do
  desc 'update mock pages'
  task :update_mocks do
    AtCoderFriends::Maintenance.update_mocks
  end
end
