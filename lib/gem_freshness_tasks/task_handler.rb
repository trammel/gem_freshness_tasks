# frozen_string_literal: true

require 'gem_freshness_tasks/bundler_client'
require 'tmpdir'

module GemFreshnessTasks
  # Implement the functionality for the rake tasks.
  class TaskHandler
    attr_reader :output_fh

    def initialize(output_fh)
      @output_fh = output_fh
    end

    def run(limit)
      perform_check(limit) { |gems| @output_fh.puts report_status(gems, limit) }
    end

    private

    def bundler_client
      @bundler_client ||= BundlerClient.new(@output_fh)
    end

    def perform_check(limit)
      gems = bundler_client.outdated
      yield(gems)
      gems.length <= limit
    end

    def report_status(gems, limit)
      gem_quantity = gems.length
      excess_quantity = gem_quantity - limit

      if excess_quantity.positive?
        failure_message(excess_quantity, gem_quantity, gems)
      elsif gem_quantity.positive?
        "[OK] You have #{gem_quantity}/#{limit} outdated gems."
      else
        '[GREAT] You have no outdated gems.'
      end
    end

    def failure_message(excess_quantity, gem_quantity, gems)
      [
        "[FAIL] You have #{gem_quantity} outdated gems. " \
            "Please update at least #{excess_quantity} of these:",
        gems.sort.map { |name| " * #{name}" }
      ].join("\n")
    end
  end
end
