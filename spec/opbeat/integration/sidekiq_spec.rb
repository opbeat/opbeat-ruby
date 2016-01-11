require 'spec_helper'

# :nocov:
begin
  require 'sidekiq'
rescue LoadError
  puts 'Skipping Sidekiq specs'
end
# :nocov:

if defined?(Sidekiq)
  require 'sidekiq/testing'

  Sidekiq::Testing.inline!
  Sidekiq::Testing.server_middleware do |chain|
    chain.add Opbeat::Integration::Sidekiq
  end

  RSpec.describe Opbeat::Integration::Sidekiq, start_without_worker: true do

    class MyWorker
      include Sidekiq::Worker

      def perform ex
        raise ex
      end
    end

    it "captures and reports exceptions to opbeat" do
      exception = Exception.new("BOOM")

      expect do
        MyWorker.perform_async exception
      end.to raise_error(Exception)

      expect(Opbeat::Client.inst.queue.length).to be 1
    end

  end
end
