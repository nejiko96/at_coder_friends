# frozen_string_literal: true

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    def open_report(file, &block)
      File.open(report_path(file), 'wb', &block)
    end

    def report_path(file)
      File.join(REGRESSION_HOME, file)
    end

    def tsv_escape(str)
      %("#{str.gsub('"', '""').gsub("\t", ' ')}")
    end
  end
end
