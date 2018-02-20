# frozen_string_literal: true

require 'pathname'
require 'yaml'

module AtCoderFriends
  # loads configuration file from the specified directory.
  class ConfigLoader
    DOTFILE = '.at_coder_friends.yml'

    class << self
      def load_config(target_dir)
        path = find_file_upwards(DOTFILE, target_dir)
        load_yaml(path)
      end

      def find_file_upwards(filename, start_dir)
        Pathname.new(start_dir).expand_path.ascend do |dir|
          file = dir + filename
          return file.to_s if file.exist?
        end
        raise ConfigNotFoundError,
              "Configuration file not found: #{start_dir}"
      end

      def load_yaml(path)
        yaml = IO.read(path, encoding: Encoding::UTF_8)
        YAML.safe_load(yaml, [], [], false, path)
      rescue Errno::ENOENT
        raise ConfigNotFoundError,
              "Configuration file not found: #{path}"
      end
    end
  end
end
