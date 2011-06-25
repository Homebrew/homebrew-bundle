# -*- encoding: utf-8 -*-
require File.expand_path('../lib/brewdler/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Nesbitt"]
  gem.email         = ["andrewnez@gmail.com"]
  gem.summary       = %q{Bundler for non-ruby dependencies from homebrew}

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "brewdler"
  gem.require_paths = ['lib']
  gem.version       = Brewdler::VERSION

  gem.add_dependency 'commander'
end
