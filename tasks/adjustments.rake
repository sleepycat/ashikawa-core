# -*- encoding : utf-8 -*-
## Specs
# Difference to Devtools:
# * Acceptance, no integration tests

Rake::Task["spec"].clear
Rake::Task["spec:integration"].clear

desc 'Run all specs'
task spec: %w[ spec:unit spec:acceptance ]

namespace :spec do
  desc "Run the acceptance tests. Requires ArangoDB to be running."
  RSpec::Core::RakeTask.new(:acceptance) do |spec|
    spec.pattern = "spec/acceptance/*_spec.rb"
  end
end

## Metrics
# Differences to Devtools:
# * Do not run mutant yet
# * metrics task only runs metrics (and not specs)

Rake::Task["ci"].clear
Rake::Task["ci:metrics"].clear

namespace :ci do
  desc 'Run all metrics except mutant and reek'
  task metrics: %w[
    metrics:coverage
    metrics:yardstick:verify
    metrics:rubocop
    metrics:flog
    metrics:flay
    metrics:reek
  ]
end

desc 'Run all metrics and specs'
task ci: %w[
  spec
  ci:metrics
]

task default: :ci
