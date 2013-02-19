# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wordpress-tools/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rodolfo Carvalho"]
  gem.email         = ["rodolfo@infweb.net"]
  gem.description   = %q{A gem to deal with wordpress sites}
  gem.summary       = %q{A gem to deal with wordpress sites}
  gem.homepage      = "http://www.infweb.net/"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "wordpress-tools"
  gem.require_paths = ["lib"]
  gem.version       = Wordpress::Tools::VERSION

  gem.add_dependency "rake"
  gem.add_dependency "compass"
  gem.add_dependency "activesupport", "~> 3.2.12"
end
