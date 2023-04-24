# frozen_string_literal: true

require_relative 'regression'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    def setup
      @emit_dir = format(EMIT_DIR_FMT, now: Time.now.strftime('%Y%m%d%H%M%S'))
      rmdir_force(@emit_dir)

      @pages_dir = format(PAGES_DIR_FMT, now: Time.now.strftime('%Y%m%d%H%M%S'))
      rmdir_force(@pages_dir)

      contest_id_list.each do |contest|
        setup_by_contest(contest)
        sleep 3
      end
    end

    def setup_by_contest(contest)
      scraping_agent(@emit_dir, contest).fetch_all do |pbm|
        setup_by_pbm(contest, pbm)
      end
    rescue StandardError => e
      puts e
      puts e.backtrace
    end

    def setup_by_pbm(contest, pbm)
      html_path = File.join(@pages_dir, contest, "#{pbm.q}.html")
      save_file(html_path, pbm.page.body)
      pipeline(pbm)
    rescue StandardError => e
      puts e
      puts e.backtrace
    end

    def save_file(path, content)
      dir = File.dirname(path)
      FileUtils.makedirs(dir)
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
