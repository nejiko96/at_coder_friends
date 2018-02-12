# frozen_string_literal: true

require 'mechanize'
require 'yaml'
require 'logger'

module AtCoderFriends
  class Agent
    def initialize(file_or_dir)
    end

    def generate(path)
      puts "AtCoderFriends::Agent::generate(#{path})"
    end

    def submit(path)
      return unless Verifier.new(@path).verified?
      puts "AtCoderFriends::Agent::submit(#{path})"
    end
  end
end
