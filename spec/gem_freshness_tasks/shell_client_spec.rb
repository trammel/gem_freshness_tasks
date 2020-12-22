# frozen_string_literal: true

require 'gem_freshness_tasks/shell_client'
require 'securerandom'

RSpec.describe GemFreshnessTasks::ShellClient do
  let(:output_fh) { instance_double(StringIO, puts: true) }

  let(:wait_thr_value) { instance_double(Process::Status, exitstatus: exitstatus, success?: false) }
  let(:wait_thr) { instance_double(Process::Waiter, value: wait_thr_value) }
  let(:input_fd) { instance_double(IO) }
  let(:mixed_output) { instance_double(IO) }
  let(:env_vars) { {} }

  before do
    allow(mixed_output).to receive(:gets).and_return(*sample_output, nil)
    allow(Open3).to receive(:popen2e).and_yield(input_fd, mixed_output, wait_thr)
  end

  describe '.run_command' do
    subject(:run_command) { described_class.new(output_fh).run_command(command, env_vars) }

    before do
      run_command
    end

    context 'with an arbitrary command' do
      let(:command) { SecureRandom.hex(5) }
      let(:sample_output) { 'Hello' }
      let(:exitstatus) { 0 }

      it 'runs the command' do
        expect(Open3).to have_received(:popen2e).with(match(/#{command}$/))
      end

      it 'has a restricted environment' do
        expect(Open3).to have_received(:popen2e).with(match(/^env -i PATH=/))
      end
    end

    context 'with arbitrary environment variables' do
      let(:command) { SecureRandom.hex(5) }
      let(:env_vars) { Hash[(0..1).map { [SecureRandom.hex(4), SecureRandom.hex(4)] }] }
      let(:sample_output) { 'Hello' }
      let(:exitstatus) { 0 }

      it 'includes the environment variables' do
        expect(Open3).to have_received(:popen2e).with(include(command))
      end

      it 'has a restricted environment' do
        env_vars.each do |key, value|
          expect(Open3).to have_received(:popen2e).with(match(/#{key}=#{value}/))
        end
      end
    end
  end
end
