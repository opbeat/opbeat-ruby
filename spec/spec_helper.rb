ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
Bundler.require :default
require 'timecop'
require 'webmock/rspec'

SimpleCov.start

require 'opbeat'

module Opbeat
  class Configuration
    # Override defaults to enable http (caught by WebMock) in test env
    defaults = DEFAULTS.dup.merge enabled_environments: %{test}
    remove_const(:DEFAULTS)
    const_set(:DEFAULTS, defaults.freeze)
  end
end

RSpec.configure do |config|
  config.before :each do
    @request_stub = stub_request(:post, /intake\.opbeat\.com/)
  end

  config.around :each, mock_time: true do |example|
    @date = Time.local(1992, 1, 1, 0, 0, 0)

    def travel distance
      Timecop.freeze(@date += distance.to_f)
    end

    travel 0
    example.run
    Timecop.return
  end

  config.around :each, start: true do |example|
    config = Opbeat::Configuration.new
    Opbeat.start! config
    example.call
    Opbeat.stop!
  end
end

RSpec::Matchers.define :delegate do |method, to:|
  match do |delegator|
    unless to.respond_to?(method)
      raise NoMethodError.new("no method :#{method} on #{to}")
    end

    allow(to).to receive(method) { true }
    delegator.send method
  end

  description do
    "delegate :#{method} to #{to}"
  end
end

