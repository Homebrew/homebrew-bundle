# -*- encoding: utf-8 -*-
require File.expand_path('../lib/brewdler/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Nesbitt", "James A. Anderson", "Amos King"]
  gem.email         = ["andrewnez@gmail.com", "me@jamesaanderson.com", "amos.l.king@gmail.com"]
  gem.summary       = %q{Bundler for non-ruby dependencies from homebrew}
  gem.licenses      = ['MIT']

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "brewdler"
  gem.require_paths = ['lib']
  gem.version       = Brewdler::VERSION

  gem.add_dependency 'commander'
  gem.add_dependency 'mime-types', '1.25'
  gem.add_development_dependency 'rspec', '~> 2.99.0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'coveralls'
end
