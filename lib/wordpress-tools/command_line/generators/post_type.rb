require 'fileutils'

module Wordpress::Tools::CommandLine::Generators
  class PostType < Base
    def generate!
      classes_path = "#{theme_path}/classes"
      render_template 'generators/post_type/post_type.php.erb', "#{classes_path}/#{class_name}.class.php",
                      :class_name => class_name, :theme_name => config.theme_name, :class_prefix => config.class_prefix
    end

    private
    def class_name
      config.class_prefix + args[1]
    end

    def target_directory
      @target_dir ||= FileUtils.pwd
    end

    def theme_path
      @theme_path ||= "#{target_directory}/wp-content/themes/#{config.theme_name}"
    end
  end
end
