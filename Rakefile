require 'bundler'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new :spec do |spec|
  spec.ruby_opts = "-I lib:spec"
  spec.pattern   = 'spec/**/*_spec.rb'
end

task :default => :spec

