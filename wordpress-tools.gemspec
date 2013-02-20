# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wordpress-tools/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rodolfo Carvalho"]
  gem.email         = ["rodolfo@infweb.net"]
  gem.description   = %q{A gem to create and manage wordpress websites}
  gem.summary       = <<-EOM 
    A gem to create and manage wordpress websites.
    In this first version, you can use the gem to initialize a blank wordpress website.
  EOM
  gem.homepage      = "http://github.com/infweb/wordpress-tools"

  gem.license       = "MIT"

  gem.required_ruby_version = '>= 1.8.7'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "wordpress-tools"
  gem.require_paths = ["lib"]
  gem.version       = Wordpress::Tools::VERSION

  gem.add_dependency "rake"
  gem.add_dependency "compass"
  gem.add_dependency "activesupport", "~> 3.2.12"
  gem.add_dependency "colorize"
end
