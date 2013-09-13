# -*- encoding : utf-8 -*-
## Specs
# Difference to Devtools:
# * Acceptance, no integration tests

Rake::Task['spec'].clear
Rake::Task['spec:integration'].clear

desc 'Run all specs'
task spec: %w[ spec:unit spec:acceptance ]

namespace :spec do
  desc 'Run the acceptance tests. Requires ArangoDB to be running.'
  RSpec::Core::RakeTask.new(:acceptance) do |spec|
    spec.pattern = 'spec/acceptance/*_spec.rb'
  end
end

## Metrics
# Differences to Devtools:
# * Do not run mutant yet

Rake::Task['ci'].clear

desc 'Run all metrics and specs'
task ci: %w[
  spec
  ci:metrics
]

task default: :ci
