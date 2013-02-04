require 'optparse'
require 'open-uri'
require 'tempfile'

module Wordpress::Tools
	class CommandLine
    attr_reader :parser, :options, :argv, :args, :action

    ACTIONS = {
      :init => "Initialize a blank project",
      :deploy => "Deploy a project"
    }

    def initialize(argv)
      @argv = argv
      @options = {
        :wp_version => "latest",
        :show_version => false,
        :show_help => false
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

      path = download_wp
      untar_wp(path, target_directory)
    end

    def on_deploy
      puts "Deploy!"
    end

    private
    def target_directory
      File.expand_path("#{args.first}")
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

      opts.separator ""
      opts.separator "deploy:"
      opts.separator "TODO"

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
	end
end