# frozen_string_literal: true

module AtCoderFriends
  # holds target path information
  class PathInfo
    SMP_DIR = 'data'
    CASES_DIR = 'cases'
    TMP_DIR = '.tmp'

    attr_reader :path, :dir

    def initialize(path)
      @path = path
      # in setup command, path is directory name (existent/non-existent)
      # in other commands(test, submit, verify), path is existent file name
      @dir = File.file?(path) ? File.dirname(path) : path
    end

    def contest_name
      File.basename(dir).delete('#').downcase
    end

    def components
      # overwrites @dir here for non-existent files (test purpose)
      @dir, prg = File.split(path)
      base, ext = prg.split('.')
      q = base.split('_')[0]
      [path, dir, prg, base, ext, q]
    end

    def src_dir
      dir
    end

    def smp_dir
      File.join(dir, SMP_DIR)
    end

    def cases_dir
      File.join(dir, CASES_DIR)
    end

    def cases_out_dir
      File.join(dir, TMP_DIR, CASES_DIR)
    end

    def tmp_dir
      File.join(dir, TMP_DIR)
    end
  end
end
