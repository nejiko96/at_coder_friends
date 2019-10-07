# frozen_string_literal: true

module AtCoderFriends
  # Common methods and behaviors for dealing with paths.
  module PathUtil
    module_function

    SMP_DIR = 'data'
    CASES_DIR = 'cases'
    TMP_DIR = '.tmp'

    def contest_name(path)
      dir = File.file?(path) ? File.dirname(path) : path
      File.basename(dir).delete('#').downcase
    end

    def split_prg_path(path)
      dir, prg = File.split(path)
      base, ext = prg.split('.')
      q = base.split('_')[0]
      [path, dir, prg, base, ext, q]
    end

    def smp_dir(dir)
      File.join(dir, SMP_DIR)
    end

    def cases_dir(dir)
      File.join(dir, CASES_DIR)
    end

    def tmp_dir(path)
      dir = File.dirname(path)
      File.join(dir, '.tmp')
    end

    def makedirs_unless(dir)
      FileUtils.makedirs(dir) unless Dir.exist?(dir)
    end
  end
end
