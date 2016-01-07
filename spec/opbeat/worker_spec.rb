require 'spec_helper'

module Opbeat
  RSpec.describe Worker do


    let :worker do
      config = Configuration.new
      @queue = Queue.new
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
    end

  end
end
