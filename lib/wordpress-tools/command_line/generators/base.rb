module Wordpress::Tools::CommandLine::Generators
  class Base
    attr_accessor :args, :options

    def initialize(args, options)
      @args = args
      @options = options
      @config = Wordpress::Tools::Configuration.new(args, options)
    end

    def generate!
      raise NotImplementedError
    end

    def valid?
      true
    end

    protected
    include Wordpress::Tools::CommandLine::Utils

    attr_reader :config
  end
end