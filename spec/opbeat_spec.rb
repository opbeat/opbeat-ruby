require 'spec_helper'

RSpec.describe Opbeat do

  it { should_not be_started }

  describe "self.start!" do
    it "delegates to client" do
      conf = Opbeat::Configuration.new app_id: 'x', organization_id: 'y', secret_token: 'z'
      expect(Opbeat::Client).to receive(:start!).with(conf) { true }
      Opbeat.start! conf
    end
    it "validates configuration" do
      conf = Opbeat::Configuration.new
      expect { Opbeat.start! conf }.to raise_error(Opbeat::Error)
    end
  end

  it { should delegate :stop!, to: Opbeat }

  describe "when Opbeat is started", start: true do
    it { should be_started }

    it { should delegate :transaction, to: Opbeat::Client.inst, args: ['Test', nil, nil] }
    it { should delegate :trace, to: Opbeat::Client.inst, args: ['test', nil, nil, {}] }
    it { should delegate :report, to: Opbeat::Client.inst, args: [Exception.new, nil] }
    it { should delegate :release, to: Opbeat::Client.inst, args: [{}, {}] }
    it { should delegate :capture, to: Opbeat::Client.inst }
  end

end
