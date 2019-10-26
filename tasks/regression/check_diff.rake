# frozen_string_literal: true

require_relative 'regression'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    def check_diff
      emit_dir = format(EMIT_DIR_FMT, now: Time.now.strftime('%Y%m%d%H%M%S'))
      rmdir_force(emit_dir)

      local_pbm_list.each do |contest, q, url|
        pbm = scraping_agent(emit_dir, contest).fetch_problem(q, url)
        pipeline(pbm)
      end

      diff_log = log_path('check_diff.txt')
      system("diff -r --exclude=.git #{EMIT_ORG_DIR} #{emit_dir} > #{diff_log}")
    end
  end
end

namespace :regression do
  desc 'run regression check'
  task :check_diff do
    AtCoderFriends::Regression.check_diff
  end
end
