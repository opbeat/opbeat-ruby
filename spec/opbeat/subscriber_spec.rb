require 'spec_helper'

module Opbeat
  RSpec.describe Subscriber do

    let(:config) { Configuration.new }
    let(:client) { Client.new config }

    subject do
      Subscriber.new config, client
    end

    describe "#register!" do
      it "subscribes to ActiveSupport::Notifications" do
        expect(ActiveSupport::Notifications).to receive(:subscribe)
        subject.register!
      end
      it "unregisters first if already registered" do
        subject.register!
        expect(subject).to receive(:unregister!)
        expect(ActiveSupport::Notifications).to receive(:subscribe)
        subject.register!
      end
    end

    describe "#unregister" do
      it "unsubscribes to AS::Notifications" do
        expect(ActiveSupport::Notifications).to receive(:unsubscribe)
        subject.register!
        subject.unregister!
      end
    end

  end
end
