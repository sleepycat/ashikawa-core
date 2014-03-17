#!/usr/bin/env rake
# -*- encoding : utf-8 -*-
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard/rake/yardoc_task'
require 'inch' # see: https://github.com/rrrene/inch/issues/7
require 'inch/rake'
require 'reek/rake/task'
require 'rubocop/rake_task'

desc 'Run all specs'
task spec: ['spec:unit', 'spec:acceptance']

namespace :spec do
  desc 'Run unit specs'
  RSpec::Core::RakeTask.new(:unit) do |task|
    task.pattern = 'spec/unit/**/*_spec.rb'
  end

  desc 'Run acceptance specs – requires running instance of ArangoDB'
  RSpec::Core::RakeTask.new(:acceptance) do |task|
    task.pattern = 'spec/acceptance/**/*_spec.rb'
  end
end

YARD::Rake::YardocTask.new(:doc)

namespace :metrics do
  Inch::Rake::Suggest.new

  Reek::Rake::Task.new do |t|
    t.fail_on_error = true
    t.config_files = 'config/reek.yml'
  end

  Rubocop::RakeTask.new do |task|
    task.options = %w[--config config/rubocop.yml]
    task.fail_on_error = true
  end

  desc 'Run mutant to check for mutation coverage'
  task :mutant do
    require 'mutant'
    require 'mutant-rspec'

    namespaces = YAML.load_file('config/mutant.yml').map { |n| "::#{n}*" }
    arguments  = %w[ --include lib --require ashikawa-core --use rspec ].concat(namespaces)
    status = Mutant::CLI.run(arguments)
    exit 'Mutant task is not successful' if status.nonzero?
  end
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
