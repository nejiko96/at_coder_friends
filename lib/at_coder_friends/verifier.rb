# frozen_string_literal: true

require 'fileutils'

module AtCoderFriends
  class Verifier
    def initialize(path)
      @path = path
      dir, @file = File.split(path)
      @vdir = "#{dir}/.tmp"
      @vpath = "#{@vdir}/#{@file}.verified"
    end

    def verify
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
