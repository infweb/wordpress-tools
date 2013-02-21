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
    include Wordpress::Tools::CommandLine::Utils

    attr_reader :config
  end
end