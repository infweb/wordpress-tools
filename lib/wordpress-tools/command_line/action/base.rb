require 'colorize'

module Wordpress::Tools::CommandLine::Action
  class Base
    attr_reader :args, :options

    def initialize(args, options={})
      @args = args
      @options = options
      @config = Wordpress::Tools::Configuration.new(args, options)
    end

    def run!
      raise NotImplementedError
    end

    def valid?
      true
    end

    protected
    attr_reader :config

    def dry_run?
      !!options[:dry_run]
    end

    def verbose?
      !!options[:verbose]
    end

    def create_directory(name, recursive=true)
      puts "[directory]".green + "\t#{name}" if verbose? or dry_run?
      return if dry_run?
      if recursive
        FileUtils.mkdir_p(name)
      else
        FileUtils.mkdir(name)
      end
    end

    def run(cmd)
      puts "[run]".green + "\t\t#{cmd}" if verbose? or dry_run?
      return if dry_run?
      puts cmd if verbose?
      result = %x|#{cmd}|
      puts result if verbose?
    end

    def render_template(name, target_path, params={})
      puts "[template]".green + "\t#{name} -> #{target_path}" if verbose? or dry_run?
      return if dry_run?
      template_file = File.expand_path("../../../../../templates/#{name}", __FILE__)
      template = Wordpress::Tools::Template.new(File.read(template_file), params)

      File.open(target_path, "w") do |f|
        f << template.render
      end
    end

    def cd_into(path)
      begin
        current = FileUtils.pwd
        puts "[cd]".green + "\t\t#{path}" if verbose? or dry_run?
        FileUtils.cd path unless dry_run?
        yield
      ensure
        puts "[cd]".green + "\t\t#{current}" if verbose? or dry_run?
        FileUtils.cd current
      end
    end

    def copy_file(name, target_path)
      puts "[file]".green + "\t\t#{name} -> #{target_path}" if verbose? or dry_run?
      return if dry_run?

      static_file = File.expand_path("../../../../../files/#{name}", __FILE__)

      File.open(target_path, "w") do |f|
        f << File.read(static_file)
      end
    end
  end
end