# frozen_string_literal: true

module AtCoderFriends
  class AppError < StandardError; end
  class ParamError < AppError; end
  class ConfigNotFoundError < AppError; end
end
