# -*- encoding : utf-8 -*-
guard 'bundler' do
  watch(/^.+\.gemspec/)
end

guard 'rspec', cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/ashikawa-core/(.+)\.rb$})     { |m| p m[1]; "spec/unit/#{m[1]}_spec.rb" }
end
