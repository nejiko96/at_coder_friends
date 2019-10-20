# frozen_string_literal: true

require_relative 'regression'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    def setup
      rmdir_force(PAGES_DIR)
      rmdir_force(EMIT_ORG_DIR)
      contest_id_list.each do |contest|
        setup_by_contest(contest)
        sleep 3
      end
    end

    def setup_by_contest(contest)
      scraping_agent(EMIT_ORG_DIR, contest).fetch_all do |pbm|
        setup_by_pbm(contest, pbm)
      end
    rescue StandardError => e
      p e
    end

    def setup_by_pbm(contest, pbm)
      html_path = File.join(PAGES_DIR, contest, "#{pbm.q}.html")
      save_file(html_path, pbm.page.body)
      pipeline(pbm)
    rescue StandardError => e
      p e
    end

    def save_file(path, content)
      dir = File.dirname(path)
      FileUtils.makedirs(dir) unless Dir.exist?(dir)
      File.binwrite(path, content)
    end
  end
end

namespace :regression do
  desc 'setup regression environment'
  task :setup do
    AtCoderFriends::Regression.setup
  end
end
