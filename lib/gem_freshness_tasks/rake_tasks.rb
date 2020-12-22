# frozen_string_literal: true

require 'rake'

module GemFreshnessTasks
  # Provide the scaffolding for the rake tasks
  class RakeTasks
    include Rake::DSL

    def initialize(handler_klazz)
      @handler_klazz = handler_klazz

      namespace :gem_freshness do
        desc 'Checks for outdated gems'
        task :run, [:limit] => [] do |_task, args|
          @handler_klazz.new($stdout).run(args.fetch(:limit).to_i) ? exit(0) : exit(1)
        end
      end
    end
  end
end
