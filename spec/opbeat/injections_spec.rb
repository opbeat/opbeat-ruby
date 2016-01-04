require 'spec_helper'

module Opbeat
  RSpec.describe Injections do

    class TestProbe
      def initialize
        @installations = 0
      end
      def install
        @installations += 1
      end
      attr_reader :installations
    end

    let(:probe) { TestProbe.new }
    subject { Opbeat::Injections }

    it "installs right away if constant is defined" do
      subject.register 'Opbeat', 'opbeat', probe
      expect(probe.installations).to be 1
    end

    it "installs a require hook" do
      subject.register 'SomeLib', 'opbeat', probe

      expect(probe.installations).to be 0

      class ::SomeLib; end
      require 'opbeat'
      expect(probe.installations).to be 1

      require 'opbeat'
      expect(probe.installations).to be 1
    end

    it "doesn't install something that never exists" do
      subject.register 'SomethingElse', 'wut', probe
      expect(probe.installations).to be 0
    end

    it "doesn't install when required but class is missing" do
      subject.register 'SomethingElse', 'opbeat', probe
      require 'opbeat'
      expect(probe.installations).to be 0
    end

  end
end
