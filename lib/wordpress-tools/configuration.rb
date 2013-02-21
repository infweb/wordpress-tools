require 'fileutils'
require 'yaml'

module Wordpress::Tools
  class Configuration
    TRANSIENT_CONFIG = [
      :dry_run, :show_version, :show_help, :skip_wordpress,
      :verbose, :wp_version
    ]

    attr_reader :action

    def initialize(args, options)
      read_configuration!
      merge_config!(args, options)
    end

    def save(path = nil)
      path = path.nil? ? config_file_path : path
      File.open(path, "w") { |f| f << @config.dup.delete_if { |k, v| TRANSIENT_CONFIG.include?(k.to_sym) }.to_yaml }
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

    def update(extra_options)
      @config.merge! extra_options
    end

    def has_config?
      !!@has_config
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
        @has_config = true
      else
        @config = {}
        @has_config = false;
      end
    end
  end
end