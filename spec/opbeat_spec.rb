require 'spec_helper'

RSpec.describe Opbeat do

  describe "when Opbeat is started", start: true do
    it { should delegate :start!, to: Opbeat }
    it { should delegate :stop!, to: Opbeat }

    it { should delegate :transaction, to: Opbeat::Client.inst }
    it { should delegate :trace, to: Opbeat::Client.inst }
    it { should delegate :report, to: Opbeat::Client.inst }
    it { should delegate :release, to: Opbeat::Client.inst }
  end

end
