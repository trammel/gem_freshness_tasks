# frozen_string_literal: true

require 'gem_freshness_tasks/rake_tasks'
require 'gem_freshness_tasks/task_handler'
GemFreshnessTasks::RakeTasks.new(GemFreshnessTasks::TaskHandler)
