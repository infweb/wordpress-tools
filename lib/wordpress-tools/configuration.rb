require 'fileutils'
require 'yaml'

module Wordpress::Tools
  class Configuration
    attr_reader :action

    def initialize(args, options)
      read_configuration!
      merge_config!(args, options)
    end

    def save
      File.open(config_file_path, "w") { |f| f << @config.to_yaml }
    end

    def target_path
      @target_path ||= FileUtils.pwd
    end

    def class_prefix
      @config[:class_prefix]
    end

    def theme_name
      @config[:theme_name]
    end

    def wordpress_version
      @config[:wordpress_version]
    end

    private
    def merge_config!(args, options)
      @config.merge!(options)
      if args.any?
        @action = args.first
      end
    end

    def config_file_path
      "#{target_path}/config.yml"
    end

    def read_configuration!
      if File.exists? config_file_path
        @config = YAML.load File.read(config_file_path)
      else
        @config = {}
      end
    end
  end
end