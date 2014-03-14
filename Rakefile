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

task default: :spec
task ci: :spec
