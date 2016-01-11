require 'spec_helper'

module Opbeat
  RSpec.describe Worker do

    before do
      @queue = Queue.new
    end

    let :worker do
      config = build_config
      Worker.new config, @queue, HttpClient.new(config)
    end

    describe "#run" do
      context "during a loop" do
        before { allow(worker).to receive(:loop).and_yield }

        subject { Thread.new { worker.run }.join 0.01 }

        it "does nothing with an empty queue" do
          subject
          expect(WebMock).to_not have_requested(:any, /.*/)
        end

        it "pops the queue" do
          @queue << Worker::PostRequest.new('/errors/', {id: 1}.to_json)
          @queue << Worker::PostRequest.new('/errors/', {id: 2}.to_json)

          subject

          expect(WebMock).to have_requested(:post, %r{/errors/$}).with(body: {id: 1})
          expect(WebMock).to have_requested(:post, %r{/errors/$}).with(body: {id: 2})
        end
      end

      context "can be stopped by sending a message" do
        it "loops until stopped" do
          thread = Thread.new do
            worker.run
          end

          @queue << Worker::StopMessage.new

          thread.join

          expect(thread).to_not be_alive
          expect(@queue).to be_empty
        end
      end
    end

  end
end
