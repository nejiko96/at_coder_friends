# frozen_string_literal: true

module AtCoderFriends
  # Common methods and behaviors for dealing with paths.
  module PathUtil
    module_function

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
  end
end
