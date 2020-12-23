# frozen_string_literal: true

require 'gem_freshness_tasks/bundler_client'
require 'securerandom'

RSpec.describe GemFreshnessTasks::BundlerClient do
  let(:output_fh) { instance_double(StringIO, puts: true) }
  let(:shell_client) do
    instance_double(GemFreshnessTasks::ShellClient, run_command: [exitstatus, bundler_output, ''])
  end
  let(:bundle_path) { SecureRandom.uuid }

  before do
    allow(GemFreshnessTasks::ShellClient).to receive(:new).and_return(shell_client)
  end

  describe '.outdated' do
    subject(:outdated) { described_class.new(output_fh).outdated }

    context 'with 6 outdated gems' do
      let(:exitstatus) { 1 }
      let(:bundler_output) do
        doc = <<~SAMPLE_OUTPUT
          #{'          '}
                    rspec-mocks (newest 3.8.1, installed 3.8.0)
                    docile (newest 1.3.2, installed 1.3.1)
                    jaro_winkler (newest 1.5.3, installed 1.5.2)
                    rspec-core (newest 3.8.1, installed 3.8.0)
                    rspec-expectations (newest 3.8.4, installed 3.8.3)
                    rspec-support (newest 3.8.2, installed 3.8.0)
        SAMPLE_OUTPUT
        doc.split(/\n/)
      end
      let(:outdated_gems) do
        bundler_output.grep(/\w+/).map { |gem| gem.match(/^\s*([\w\-]+)/).captures.first }.sort
      end

      before do
        ENV['BUNDLE_PATH'] = bundle_path
        outdated
      end

      it 'shells out to call bundler for outdated gems' do
        expect(shell_client).to have_received(:run_command).with('bundle outdated', match(anything))
      end

      it 'results in a sorted list of 6 gems' do
        expect(outdated).to eq(outdated_gems)
      end

      it 'uses the BUNDLE_PATH variable if provided in ENV' do
        expect(shell_client).to have_received(
          :run_command
        ).with(match(anything), 'BUNDLE_PATH' => bundle_path, 'GEM_HOME' => bundle_path)
      end
    end

    context 'with a bundler error (non 0/1 exit status)' do
      let(:exitstatus) { 2 }
      let(:bundler_output) { ['Something bad happened'] }

      it 'raises an error' do
        expect { outdated }.to raise_error(match(/^Failed to run bundler/))
      end
    end
  end
end
