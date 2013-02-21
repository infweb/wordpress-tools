module Wordpress::Tools::CommandLine::Action
  class Generate < Base
    attr_accessor :what, :name

    def run!
      generator.generate!
    end

    def generator
      begin
      @generator_class ||= "Wordpress::Tools::CommandLine::Generators::#{what.classify}".constantize
      @generator ||= @generator_class.new(args, options)
      rescue NameError
        nil
      end
    end

    def what
      @what ||= args.first
    end

    def name
      @name ||= args[1]
    end

    def valid?
      config.has_config? and args.length >= 2 and generator.present? and generator.valid?
    end
  end
end