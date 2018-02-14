# frozen_string_literal: true

require 'fileutils'

module AtCoderFriends
  class Verifier
    def initialize(path)
      @path = path
      @file = File.basename(path)
      @vdir = File.join(File.dirname(path), '.tmp')
      @vpath = File.join(@vdir, "#{@file}.verified")
    end

    def verify
      return unless File.exist?(@path)
      Dir.mkdir(@vdir) unless Dir.exist?(@vdir)
      FileUtils.touch(@vpath)
    end

    def unverify
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
