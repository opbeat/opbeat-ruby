require 'spec_helper'

module Opbeat
  RSpec.describe Util::Inspector, start: true, mock_time: true do

    let(:transaction) do
      Opbeat.transaction 'Test' do |transaction|
        travel 0.1
        Opbeat.trace('test 1') { travel 0.1 }
        travel 0.1
        Opbeat.trace('test 2') { travel 0.15 }
        travel 0.1

        transaction
      end
    end
    subject do
      Util::Inspector.new.transaction(transaction)
    end

    it "doesn't explode" do
      expect { subject }.to_not raise_error
    end

    it "doesn't exceed it's length" do
      expect(subject.split("\n").map(&:length).find { |l| l < 100 })
    end

    # it "is beautiful" do
    #   puts subject
    # end
  end
end
