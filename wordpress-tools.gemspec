# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wordpress-tools/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rodolfo Carvalho"]
  gem.email         = ["rodolfo@infweb.net"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = "http://www.infweb.net/"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "wordpress-tools"
  gem.require_paths = ["lib"]
  gem.version       = Wordpress::Tools::VERSION

  gem.add_dependency "rake"
end
