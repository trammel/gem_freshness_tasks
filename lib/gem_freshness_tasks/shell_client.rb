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
      Open3.popen2e(environment_restricted(command, env)) do |_stdin, mixed_output, wait_thr|
        lines = []
        while (line = mixed_output.gets)
          lines << line
          @output_fh.puts line
        end
        @output_fh.puts("Exited with: #{wait_thr.value.exitstatus}")
        [wait_thr.value.exitstatus, lines]
      end
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
