$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'content-security-policy/version'

Gem::Specification.new do |s|
  s.name     = 'content-security-policy'
  s.version  = ContentSecurityPolicy::VERSION

  s.author = 'Alex Rodionov'
  s.email  = 'p0deje@gmail.com'

  s.homepage    = 'https://github.com/p0deje/content-security-policy'
  s.summary     = 'Content Security Policy for Rack'
  s.description = <<-EOF
    Implementation of Content Security Policy as Rack middleware.
    More information about Content Security Policy - http://http://www.w3.org/TR/CSP/.
  EOF

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  s.require_path = 'lib'

  s.add_dependency 'rack'

  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
end

