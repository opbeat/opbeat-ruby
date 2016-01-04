require 'spec_helper'
require 'opbeat'

module Opbeat
  describe Logging do
    class FakeLogger
      def method_missing name, *args, &block
        @calls ||= []
        @calls << [name, *args]
      end
      attr_reader :calls
    end

    let(:logger) { FakeLogger.new }
    let(:config) { Struct.new(:logger).new(logger) }

    before :each do
      extend Logging
    end

    %w{fatal error info debug warn}.map(&:to_sym).each do |level|
      it "does #{level} with args" do
        self.send level, "msg"
        expect(logger.calls.last).to eq [level, "** [Opbeat] msg"]
      end
      it "does #{level} with block" do
        blck = lambda { "msg" }
        self.send level, &blck
        expect(logger.calls.last).to eq [level, "** [Opbeat] msg"]
      end
    end

    context 'without a backend logger' do
      before do
        config.logger = nil
      end

      it 'should not error' do
        fatal 'fatalmsg'
        error 'errormsg'
        warn 'warnmsg'
        info 'infomsg'
        debug 'debugmsg'
      end
    end
  end
end
