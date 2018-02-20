# frozen_string_literal: true

module AtCoderFriends
  class ApplicationError < StandardError; end
  class ParameterError < ApplicationError; end
  class ConfigNotFoundError < ApplicationError; end
end
