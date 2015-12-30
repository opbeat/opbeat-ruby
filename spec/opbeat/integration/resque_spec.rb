require 'spec_helper'

# :nocov:
begin
  require 'resque'
rescue LoadError
  puts 'Skipping Resque specs'
end
# :nocov:

if defined? Resque
  RSpec.describe 'Resque integration', start: true do

    before do
      # mocking redis is a bit much, but sadly necessary
      require 'mock_redis'
      Resque.redis = MockRedis.new

      require 'resque/failure/multiple'
      Resque::Failure::Multiple.classes = [Opbeat::Integration::Resque]
      Resque::Failure.backend = Resque::Failure::Multiple
    end

    class MyWorker
      @queue = :default

      def self.perform txt
        raise Exception.new txt
      end
    end

    it "captures and reports exceptions" do
      Resque.enqueue MyWorker, "BOOM"

      worker = Resque::Worker.new(:default)
      job = worker.reserve
      worker.perform job

      expect(WebMock).to have_requested(:post, %r{/errors/$}).with({
        body: /{"message":"Exception: BOOM"/
      })
    end

  end
end
