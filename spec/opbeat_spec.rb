require 'spec_helper'

RSpec.describe Opbeat do

  it { should_not be_started }

  describe "self.start!" do
    it "delegates to client" do
      conf = Opbeat::Configuration.new app_id: 'x', organization_id: 'y', secret_token: 'z'
      expect(Opbeat::Client).to receive(:start!).with(conf) { true }
      Opbeat.start! conf
    end
  end

  it { should delegate :stop!, to: Opbeat }

  describe "when Opbeat is started", start: true do
    it { should be_started }

    it { should delegate :transaction, to: Opbeat::Client.inst, args: ['Test', nil, nil] }
    it { should delegate :trace, to: Opbeat::Client.inst, args: ['test', nil, {}] }
    it { should delegate :report, to: Opbeat::Client.inst, args: [Exception.new, nil] }
    it { should delegate :set_context, to: Opbeat::Client.inst, args: [{}] }
    it { should delegate :report_message, to: Opbeat::Client.inst, args: ["My message", nil] }
    it { should delegate :release, to: Opbeat::Client.inst, args: [{}, {}] }
    it { should delegate :capture, to: Opbeat::Client.inst }

    describe "a block example", mock_time: true do
      it "is done" do
        transaction = Opbeat.transaction 'Test' do
          travel 100
          Opbeat.trace 'test1' do
            travel 100
            Opbeat.trace 'test1-1' do
              travel 100
            end
            Opbeat.trace 'test1-2' do
              travel 100
            end
            travel 100
          end
        end.done(true)

        expect(transaction).to be_done
        expect(transaction.duration).to eq 500_000_000
      end
    end
  end

end
