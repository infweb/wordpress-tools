module Wordpress::Tools::Action
  class Base
    attr_reader :args, :options

    def initialize(args, options={})
      @args = args
      @config = Wordpress::Tools::Configuration.new(args, options)
    end

    def run!
      raise NotImplementedError
    end

    def valid?
      true
    end

    protected

    def run(cmd)
      if options[:dry_run]
        puts cmd
      else
        puts cmd if options[:verbose]
        result = %x|#{cmd}|
        puts result if options[:verbose]
      end
    end

    def render_template(name, target_path, params={})
      template_file = File.expand_path("../../../../../templates/#{name}", __FILE__)
      template = Wordpress::Tools::Template.new(File.read(template_file), params)

      File.open(target_path, "w") do |f|
        f << template.render
      end
    end

    def copy_file(name, target_path)
      static_file = File.expand_path("../../../../../files/#{name}", __FILE__)

      File.open(target_path, "w") do |f|
        f << File.read(static_file)
      end
    end
  end
end