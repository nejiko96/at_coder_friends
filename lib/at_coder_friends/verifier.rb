# frozen_string_literal: true

require 'fileutils'

module AtCoderFriends
  # marks and checks if the source has been verified.
  class Verifier
    include PathUtil

    attr_reader :path, :file, :vdir, :vpath

    def initialize(ctx)
      @path, _dir, @file = ctx.path_info.components
      @vdir = ctx.path_info.tmp_dir
      @vpath = File.join(vdir, "#{file}.verified")
    end

    def verify
      return unless File.exist?(path)

      makedirs_unless(vdir)
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
