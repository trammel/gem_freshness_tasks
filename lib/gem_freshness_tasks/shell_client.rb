# frozen_string_literal: true

require 'open3'
require 'shellwords'

module GemFreshnessTasks
  # Handles interaction with the shell.
  class ShellClient
    def initialize(output_fh)
      @output_fh = output_fh
    end

    def run_command(command, env = {})
      stdout, stderr, status = Open3.capture3(environment_restricted(command, env))

      stdout.split(/\n/).each do |line|
        @output_fh.puts line
      end

      @output_fh.puts("Exited with: #{status.exitstatus}")
      [status.exitstatus, stdout.split(/\n/), stderr.split(/\n/)]
    end

    private

    def environment_restricted(command, env)
      "env -i PATH=#{escaped_path} #{env_string(env)} #{command}"
    end

    def env_string(env)
      env.map { |k, v| "#{k}=#{v}" }.join(' ')
    end

    def escaped_path
      Shellwords.escape(ENV['PATH'])
    end
  end
end
