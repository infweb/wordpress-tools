require 'optparse'
require 'open-uri'
require 'tempfile'
require 'erb'
require 'active_support/core_ext'

module Wordpress::Tools
  module CommandLine
    autoload :Action, 'wordpress-tools/command_line/action'
    autoload :Generators, 'wordpress-tools/command_line/generators'
    autoload :Utils, 'wordpress-tools/command_line/utils'

    class Parser
      attr_reader :parser, :options, :argv, :args, :action

      ACTIONS = {
        :init => "Initialize a blank project",
        :generate => "Generate code for elements",
      }

      def initialize(argv)
        @argv = argv
        @options = {
          :wp_version => "latest",
          :show_version => false,
          :show_help => false,
          :skip_wordpress => false,
          :dry_run => false,
          :verbose => false
        }

        @parser = OptionParser.new { |opts| setup(opts) }
      end

      def parse!
        @action, *@args = @parser.parse!(@argv)
        validate!
        current_action.run!
      end

      private

      def current_action
        begin
          clazz = "Wordpress::Tools::CommandLine::Action::#{action.to_s.camelize}".constantize
          @action_obj ||= clazz.new(args, options)
        rescue => ex
          puts ex
          puts ex.backtrace
          nil
        end
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

        if current_action.nil?
          puts "Unimplemented action: #{action}"
          exit -3
        end

        unless current_action.valid?
          puts "Invalid parameters for action: #{action}"
          exit -5
        end
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

        opts.on("-V", "--verbose") do
          options[:verbose] = true
        end

        opts.on("--dry-run") do
          options[:dry_run] = true
        end

        opts.on("-c", "--class-prefix CLASS_PREFIX", "Prefix for all theme-related classes") do |cp|
          options[:class_prefix] = cp
        end

        opts.on_tail("-h", "--help", "Print this message") do
          options[:show_help] = true
          puts opts
        end
      end
    end
  end
end