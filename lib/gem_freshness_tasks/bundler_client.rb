# frozen_string_literal: true

require 'open3'
require_relative './shell_client'

module GemFreshnessTasks
  # Handles all the IO interaction with bundler, through the command
  # line, rather than through the library, because it's not really
  # built to used in any other way.
  class BundlerClient
    def initialize(output_fh)
      @shell_client = GemFreshnessTasks::ShellClient.new(output_fh)
    end

    def outdated
      run_commands_or_fail(['bundle outdated'], bundler_env)
        .flatten
        .grep(/^\s+\*\s+\w/)
        .map { |gem| gem.match(/^\s+\*\s+([\w\-]+)/).captures.first }
        .sort
    end

    private

    def bundler_env
      ENV.slice('BUNDLE_PATH').merge('GEM_HOME' => ENV['BUNDLE_PATH'])
    end

    def run_commands_or_fail(commands, env)
      output = []
      commands.each do |command|
        exit_value, command_output, _error_output = @shell_client.run_command(command, env)
        output << command_output
        raise("Failed to run bundler: #{output}") unless [0, 1].include?(exit_value)
      end
      output
    end
  end
end
