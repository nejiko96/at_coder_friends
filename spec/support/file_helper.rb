# frozen_string_literal: true

require 'fileutils'

# Common methods for dealing with files.
module FileHelper
  def create_file(file_path, content)
    file_path = File.expand_path(file_path)
    dir_path = File.dirname(file_path)
    FileUtils.makedirs(dir_path) unless Dir.exist?(dir_path)

    File.open(file_path, 'w') do |file|
      case content
      when String
        file.puts content
      when Array
        file.puts content.join("\n")
      end
    end
  end

  def rmdir_force(dir)
    FileUtils.rm_r(dir) if Dir.exist?(dir)
  end
end
