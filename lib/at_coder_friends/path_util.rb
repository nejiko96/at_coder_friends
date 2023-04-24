# frozen_string_literal: true

module AtCoderFriends
  # Common methods and behaviors for dealing with paths.
  module PathUtil
    def makedirs_unless(dir)
      FileUtils.makedirs(dir)
    end
  end
end
