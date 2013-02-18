require 'optparse'
require 'open-uri'
require 'tempfile'
require 'fileutils'
require 'erb'

module Wordpress::Tools
  class CommandLine
    attr_reader :parser, :options, :argv, :args, :action

    ACTIONS = {
      :init => "Initialize a blank project"
    }

    def initialize(argv)
      @argv = argv
      @options = {
        :wp_version => "latest",
        :show_version => false,
        :show_help => false,
        :skip_wordpress => false
      }

      @parser = OptionParser.new { |opts| setup(opts) }
    end

    def parse!
      @action, *@args = @parser.parse!(@argv)
      validate!
      nil
    end

    # Actions
    def on_init
      if args.empty?
        puts "You must specify a main theme name."
        puts @parser
        exit -1
      end

      unless options[:skip_wordpress]
        path = download_wp
        untar_wp(path, target_directory) 
      end
      bootstrap_theme(target_directory, main_theme_name)
      add_to_vcs(target_directory)
      render_template('config.yml.erb', File.join(target_directory, 'config.yml'), 
        :theme_name => main_theme_name)
      render_template('build.xml.erb', File.join(target_directory, 'build.xml'),
        :app_name => main_theme_name)
      render_template('build.properties.erb', File.join(target_directory, 'build.properties'),
        :app_name => main_theme_name)
      # TODO:
      # compass setup
      # database setup (?)
    end

    private
    def add_to_vcs(path)
      current = FileUtils.pwd
      begin
        FileUtils.cd(path)
        puts %x|git init .|
        File.open('.gitignore', 'w') do |f|
          l = %w(index.php license.txt readme.html wp-activate.php wp-admin/ wp-blog-header.php
            wp-comments-post.php wp-config-sample.php wp-cron.php wp-includes wp-links-opml.php
            wp-load.php wp-login.php wp-mail.php wp-settings.php wp-signup.php wp-trackback.php
            xmlrpc.php wp-content/languages)
          l.each { |pattern| f << pattern + "\n" }
        end
      ensure
        FileUtils.cd(current)
      end
    end

    def bootstrap_theme(target_dir, theme_name)
      theme_path = File.join(target_dir, "wp-content", "themes", theme_name)
      FileUtils.mkdir_p(theme_path)
      render_template "functions.php.erb", File.join(theme_path, "functions.php"), :theme_name => theme_name
      render_template "style.css.erb", File.join(theme_path, "style.css"), :theme_name => theme_name
      puts %|cd #{theme_path}; compass create .|
    end

    def main_theme_name
      args.first
    end

    def target_directory
      File.expand_path("#{main_theme_name}")
    end

    def untar_wp(from, to)
      wp_src_dir = File.join File.dirname(from), "wordpress"

      cmd = "tar -xzvf #{from} -C #{File.dirname(from)}"
      puts "Running #{cmd}..."
      puts %x|#{cmd}|
      puts %x|mv -v #{wp_src_dir} #{to}|
    end

    def download_wp
      tmp = Tempfile.new('wp')
      puts "Downloading Wordpress from #{wp_download_link}..."
      open(wp_download_link) do |io|
        tmp << io.read
        tmp.path
      end
    end

    def wp_download_link
      "http://br.wordpress.org/#{options[:wp_version]}-pt_BR.tar.gz"
    end

    def validate!
      exit 0 if options[:show_version] || options[:show_help]

      if action.to_s.strip.empty?
        puts "You must specify an action."
        puts @parser
        exit -1
      end

      unless ACTIONS.keys.any? { |a| a.to_s == action }
        puts "Invalid action: #{action}"
        puts @parser
        exit -2
      end

      unless respond_to?("on_#{action}")
        puts "Unimplemented action: #{action}"
        exit -3
      end

      send("on_#{action}")
    end

    def setup(opts)
      opts.banner = "Usage: wp action [OPTIONS]"
      opts.separator ""
      opts.separator "Available actions:"
      opts.separator ACTIONS.keys.map(&:to_s).join(" ")

      opts.separator ""
      opts.separator "init:"
      opts.separator "Example: wp init <main_theme_name> [OPTIONS]"

      opts.on("--wordpress-version=[WORDPRESS_VERSION]", 
        "Wordpress Version to use. Default: #{options[:wp_version]}") do |v|
        options[:wp_version] = v
      end

      opts.on("--skip-wordpress", "Skips wordpress download (Assumes an existing wordpress site)") do
        options[:skip_wordpress] = true
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on("-v", "--version", "Show the program version") do
        options[:show_version] = true
        puts "wp (wodpress-tools) version #{Wordpress::Tools::VERSION}"
      end

      opts.on_tail("-h", "--help", "Print this message") do
        options[:show_help] = true
        puts opts
      end
    end

    def render_template(name, target_path, params={})
      template_file = File.expand_path("../../../templates/#{name}", __FILE__)
      template = Template.new(File.read(template_file), params)

      File.open(target_path, "w") do |f|
        f << template.render
      end
    end
  end
end