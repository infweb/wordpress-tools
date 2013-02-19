require "wordpress-tools/version"

module Wordpress
  module Tools
    autoload :CommandLine, 'wordpress-tools/command_line'
    autoload :Template, 'wordpress-tools/template'
    autoload :Configuration, 'wordpress-tools/configuration'
  end
end
