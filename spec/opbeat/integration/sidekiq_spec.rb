require 'spec_helper'

begin
  require 'sidekiq'
rescue LoadError
  puts 'Skipping Sidekiq specs'
end

if defined?(Sidekiq)
  require 'sidekiq/testing'

  Sidekiq::Testing.inline!
  Sidekiq::Testing.server_middleware do |chain|
    chain.add Opbeat::Integration::Sidekiq
  end

  RSpec.describe Opbeat::Integration::Sidekiq, start: true do

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

      expect(WebMock).to have_requested(:post, %r{/errors/$}).with({
        body: /{"message":"RuntimeError: BOOM"/
      })
    end

  end
end
