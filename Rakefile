# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError => e
  puts e
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require_relative 'lib/gem_freshness_tasks'

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end
RSpec::Core::RakeTask.new(:spec)

desc 'Run all rubocop and rspec tests'
task default: %w[spec rubocop]
