#!/usr/bin/env rake
# -*- encoding : utf-8 -*-
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc 'Run all specs'
task spec: ['spec:unit', 'spec:acceptance']

namespace :spec do
  desc 'Run unit specs'
  RSpec::Core::RakeTask.new(:unit) do |task|
    task.pattern = 'spec/unit/**/*_spec.rb'
  end

  desc 'Run acceptance specs'
  RSpec::Core::RakeTask.new(:acceptance) do |task|
    task.pattern = 'spec/acceptance/**/*_spec.rb'
  end
end

require 'yard/rake/yardoc_task'

YARD::Rake::YardocTask.new

require 'inch'
require 'inch/rake'

Inch::Rake::Suggest.new

require 'reek/rake/task'

Reek::Rake::Task.new do |t|
  t.fail_on_error = true
  t.config_files = 'config/reek.yml'
end

require 'rubocop/rake_task'

Rubocop::RakeTask.new do |task|
  task.options = %w[--config config/rubocop.yml]
  task.fail_on_error = true
end

require 'mutant'
require 'mutant-rspec'

desc 'Run mutant to check for mutation coverage'
task :mutant do
  namespaces = YAML.load_file('config/mutant.yml').map { |n| "::#{n}*" }
  arguments  = %w[ --include lib --require ashikawa-core --use rspec ].concat(namespaces)
  status = Mutant::CLI.run(arguments)
  exit 'Mutant task is not successful' if status.nonzero?
end

desc 'Start a REPL with guacamole loaded (not the Rails part)'
task :console do
  require 'bundler/setup'

  require 'pry'
  require 'ashikawa-core'
  ARGV.clear
  Pry.start
end

task default: :spec
task ci: :spec
