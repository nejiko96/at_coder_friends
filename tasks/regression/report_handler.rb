# frozen_string_literal: true

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    def open_report(file)
      File.open(report_path(file), 'wb') { |f| yield f }
    end

    def report_path(file)
      File.join(REGRESSION_HOME, file)
    end

    def tsv_escape(str)
      '"' + str.gsub('"', '""').gsub("\t", ' ') + '"'
    end
  end
end
