# frozen_string_literal: true

require 'gem_freshness_tasks/rake_tasks'
require 'gem_freshness_tasks/task_handler'

# Holy shit is trying to write specs for rake a nightmare. It's caching
# of rake tasks means you have to clear the application before every
# test, or it'll cache all of your test doubles for you.
RSpec.describe GemFreshnessTasks::RakeTasks do
  %i[run].each do |method|
    describe "gem_freshness:#{method}" do
      subject(:invocation) { task.invoke(limit) }

      let(:task_handler) { instance_double(GemFreshnessTasks::TaskHandler) }
      let(:handler_result) { nil }
      let(:task) do
        Rake.application.clear
        described_class.new(GemFreshnessTasks::TaskHandler)
        Rake.application["gem_freshness:#{method}"]
      end

      before do
        allow(GemFreshnessTasks::TaskHandler).to receive(:new).and_return(task_handler)
        allow(task_handler).to receive(method).and_return(handler_result)
      end

      context 'with a limit' do
        let(:limit) { 5 }

        # rubocop:disable Lint/SuppressedException
        before do
          invocation
        rescue SystemExit
        end
        # rubocop:enable Lint/SuppressedException

        it 'passes the limit to the handler as an integer' do
          expect(task_handler).to have_received(method).with(limit.to_i)
        end
      end

      context 'when the handler returns true' do
        let(:handler_result) { true }
        let(:limit) { 5 }

        it 'exits normally' do
          expect { invocation }.to raise_error(
            an_instance_of(SystemExit).and(having_attributes(status: 0))
          )
        end
      end

      context 'when the handler returns false' do
        let(:handler_result) { false }
        let(:limit) { 5 }

        # rubocop:disable RSpec/MultipleExpectations
        it 'exits with an error status' do
          expect { invocation }.to raise_error(SystemExit) do |error|
            expect(error.status).not_to eq(0)
          end
        end
        # rubocop:enable RSpec/MultipleExpectations
      end
    end
  end
end
