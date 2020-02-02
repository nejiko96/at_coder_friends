# frozen_string_literal: true

require 'pathname'
require 'yaml'

module AtCoderFriends
  # loads configuration file from the specified directory.
  class ConfigLoader
    DOTFILE = '.at_coder_friends.yml'
    ACF_HOME = File.realpath(File.join(__dir__, '..', '..'))
    DEFAULT_FILE = File.join(ACF_HOME, 'config', 'default.yml')

    class << self
      def dotfile
        DOTFILE
      end

      def default_file
        DEFAULT_FILE
      end

      def load_config(ctx)
        path = config_file_for(ctx.path)
        config = load_yaml(path)
        return config if path == default_file

        merge_with_default(config)
      end

      def config_file_for(target_dir)
        find_project_dotfile(target_dir) || default_file
      end

      def find_project_dotfile(target_dir)
        find_file_upwards(dotfile, target_dir)
      end

      def find_file_upwards(filename, start_dir)
        Pathname.new(start_dir).expand_path.ascend do |dir|
          file = dir + filename
          return file.to_s if file.exist?
        end
      end

      def merge_with_default(config)
        merge(default_config, config)
      end

      def default_config
        load_yaml(DEFAULT_FILE)
      end

      def merge(base_hash, derived_hash)
        res = base_hash.merge(derived_hash) do |_, base_val, derived_val|
          if base_val.is_a?(Hash) && derived_val.is_a?(Hash)
            merge(base_val, derived_val)
          else
            derived_val
          end
        end
        res
      end

      def load_yaml(path)
        yaml = IO.read(path, encoding: Encoding::UTF_8)
        YAML.safe_load(yaml, [], [], false, path) || {}
      rescue Errno::ENOENT
        raise ConfigNotFoundError,
              "Configuration file not found: #{path}"
      end
    end
  end
end
