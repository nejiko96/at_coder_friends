# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

Dir['tasks/**/*.rake'].each { |t| load t }

task default: :spec
