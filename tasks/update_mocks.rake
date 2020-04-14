# frozen_string_literal: true

module AtCoderFriends
  # miscellaneous tasks
  module Misc
    module_function
    URL_BASE = 'https://atcoder.jp/'
    ACF_HOME = File.expand_path(File.join(__dir__, '..'))
    MOCK_BASE = File.join(ACF_HOME, 'spec', 'mocks')
    MOCK_PAGES = %w[
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
      /contests/practice/tasks
      /contests/practice/tasks/practice_1
      /contests/practice/tasks/practice_2
      /contests/practice/custom_test
      /contests/practice/submit
      /contests/tdpc/tasks
      /contests/tdpc/tasks/tdpc_contest
    ].freeze

    def update_mocks
      agent = Context.new({}, __FILE__).scraping_agent
      MOCK_PAGES.each do |path|
        url = File.join(URL_BASE, path)
        file = File.join(MOCK_BASE, path + '.html')
        puts "#{url} -> #{file}"
        page = agent.fetch_with_auth(url)
        File.binwrite(file, page.body)
      end
    end
  end
end

namespace :misc do
  desc 'update mock pages'
  task :update_mocks do
    AtCoderFriends::Misc.update_mocks
  end
end
