module Wordpress::Tools::CommandLine
  module Action
    autoload :Base, 'wordpress-tools/command_line/action/base'
    autoload :Init, 'wordpress-tools/command_line/action/init'
    autoload :Generate, 'wordpress-tools/command_line/action/generate'
  end
end