# frozen_string_literal: true

require 'fileutils'

module AtCoderFriends
  # marks and checks if the source has been verified.
  class Verifier
    attr_reader :path, :file, :vdir, :vpath

    def initialize(ctx)
      @path = ctx.path
      @file = File.basename(path)
      @vdir = File.join(File.dirname(path), '.tmp')
      @vpath = File.join(vdir, "#{file}.verified")
    end

    def verify
      return unless File.exist?(path)

      FileUtils.makedirs(vdir) unless Dir.exist?(vdir)
      FileUtils.touch(vpath)
    end

    def unverify
      return unless File.exist?(vpath)

      File.delete(vpath)
    end

    def verified?
      return false unless File.exist?(vpath)
      return false if File.mtime(vpath) < File.mtime(path)

      true
    end
  end
end
