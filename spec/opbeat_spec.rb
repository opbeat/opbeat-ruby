require 'spec_helper'

RSpec.describe Opbeat do

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

  describe "when Opbeat is started" do
    before { Opbeat.start! }
    after  { Opbeat.stop! }

    it { should delegate :start!, to: Opbeat }
    it { should delegate :stop!, to: Opbeat }

    it { should delegate :transaction, to: Opbeat::Client.inst }
    it { should delegate :trace, to: Opbeat::Client.inst }
    it { should delegate :report, to: Opbeat::Client.inst }
    it { should delegate :release, to: Opbeat::Client.inst }
  end

end
