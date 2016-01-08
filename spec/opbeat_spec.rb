require 'spec_helper'

RSpec.describe Opbeat do

  it { should_not be_started }

  describe "when Opbeat is started", start: true do
    it { should delegate :start!, to: Opbeat }
    it { should delegate :stop!, to: Opbeat }

    it { should delegate :transaction, to: Opbeat::Client.inst, args: ['Test', nil, nil] }
    it { should delegate :trace, to: Opbeat::Client.inst, args: ['test', nil, nil, {}] }
    it { should delegate :report, to: Opbeat::Client.inst, args: [Exception.new, nil] }
    it { should delegate :release, to: Opbeat::Client.inst, args: [{}] }
    it { should delegate :capture, to: Opbeat::Client.inst }

    it { should be_started }
  end

end
