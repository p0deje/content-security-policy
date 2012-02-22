$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'content-security-policy/version'

Gem::Specification.new do |s|
  s.name     = 'content-security-policy'
  s.version  = ContentSecurityPolicy::VERSION

  s.author = 'Alex Rodionov'
  s.email  = 'p0deje@gmail.com'

  s.homepage    = 'https://github.com/p0deje/content-security-policy'
  s.summary     = 'Full-featured Content Security Policy as Rack middleware'
  s.description = 'Full-featured Content Security Policy as Rack middleware'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  s.require_path = 'lib'

  s.add_dependency 'rack', '~> 1.4'

  s.add_development_dependency 'rack-test' , '~> 0.6'
  s.add_development_dependency 'rspec'     , '~> 2.8'
  s.add_development_dependency 'rake'      , '~> 0.9'
end
