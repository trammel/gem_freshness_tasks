# frozen_string_literal: true

require 'gem_freshness_tasks/task_handler'
require 'gem_freshness_tasks/bundler_client'
require 'securerandom'

RSpec.describe GemFreshnessTasks::TaskHandler do
  before do
    allow(GemFreshnessTasks::BundlerClient).to receive(:new).and_return(bundler_client)
  end

  let(:output_fh) { instance_double(StringIO, puts: true) }

  describe '.run' do
    subject(:run) do
      described_class.new(output_fh).run(limit)
    end

    let(:bundler_client) do
      instance_double(
        GemFreshnessTasks::BundlerClient, outdated: outdated_gems
      )
    end

    before do
      run
    end

    context 'with a limit of 5' do
      let(:limit) { 5 }

      context 'with 0 outdated gems' do
        let(:exit_status) { 1 }
        let(:outdated_gems) { [] }
        let(:success_message) do
          '[GREAT] You have no outdated gems.'
        end

        it 'asks the bundler client for the information' do
          expect(bundler_client).to have_received(:outdated)
        end

        it 'outputs a summary with numeric advice' do
          expect(output_fh).to have_received(:puts).with(include(success_message))
        end

        it 'returns true' do
          expect(run).to eq(true)
        end
      end

      context 'with 3 outdated gems' do
        let(:exit_status) { 1 }
        let(:outdated_gems) { Array.new(3) { SecureRandom.hex(4) } }
        let(:success_message) do
          '[OK] You have 3/5 outdated gems.'
        end

        it 'asks the bundler client for the information' do
          expect(bundler_client).to have_received(:outdated)
        end

        it 'outputs a summary with numeric advice' do
          expect(output_fh).to have_received(:puts).with(include(success_message))
        end

        it 'returns true' do
          expect(run).to eq(true)
        end
      end

      context 'with 10 outdated gems' do
        let(:exit_status) { 1 }
        let(:outdated_gems) { Array.new(10) { SecureRandom.hex(4) } }
        let(:failure_message) do
          '[FAIL] You have 10 outdated gems. Please update at least 5 of these:'
        end

        it 'asks the bundler client for the information' do
          expect(bundler_client).to have_received(:outdated)
        end

        it 'outputs a summary with numeric advice' do
          expect(output_fh).to have_received(:puts).with(include(failure_message))
        end

        it 'outputs the sorted gems that can be updated' do
          expect(output_fh).to have_received(:puts).with(include(outdated_gems.sort.join("\n \* ")))
        end

        it 'returns false' do
          expect(run).to eq(false)
        end
      end
    end
  end
end
