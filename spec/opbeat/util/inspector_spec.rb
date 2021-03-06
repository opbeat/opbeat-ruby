require 'spec_helper'

module Opbeat
  RSpec.describe Util::Inspector, start_without_worker: true, mock_time: true do

    let(:transaction) do
      Opbeat.transaction 'Test' do |transaction|
        travel 10
        Opbeat.trace('test 1', 'trace.test') do
          travel 100
          Opbeat.trace('test 2', 'trace.test') { travel 150 }
          travel 50
        end
        travel 50
        Opbeat.trace('test 3', 'trace.test') do
          travel 100
        end
        travel 1

        transaction
      end
    end
    subject do
      Util::Inspector.new.transaction(transaction, include_parents: true)
    end

    it "doesn't explode" do
      expect { subject }.to_not raise_error
    end

    it "doesn't exceed it's length" do
      expect(subject.split("\n").map(&:length).find { |l| l < 100 })
    end

    # preview
    it "is beautiful" do
      puts subject
    end
  end
end
