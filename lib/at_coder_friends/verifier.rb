# frozen_string_literal: true

require 'fileutils'

module AtCoderFriends
  # marks and checks if the source has been verified.
  class Verifier
    def initialize(path)
      @path = path
      @file = File.basename(path)
      @vdir = File.join(File.dirname(path), '.tmp')
      @vpath = File.join(@vdir, "#{@file}.verified")
    end

    def verify
      return unless File.exist?(@path)
      FileUtils.makedirs(@vdir) unless Dir.exist?(@vdir)
      FileUtils.touch(@vpath)
    end

    def unverify
      return unless File.exist?(@vpath)
      File.delete(@vpath)
    end

    def verified?
      unless File.exist?(@vpath)
        puts "#{@file} is not verified."
        return false
      end
      if File.mtime(@vpath) < File.mtime(@path)
        puts "#{@file} is not verified."
        return false
      end
      true
    end
  end
end
