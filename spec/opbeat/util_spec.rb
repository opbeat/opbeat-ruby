require 'spec_helper'

module Opbeat
  RSpec.describe Util do

    describe "#nearest_minute", mock_time: true do
      it "normalizes to nearest minute" do
        travel 125_000 # two minutes five secs
        expect(Util.nearest_minute).to eq Time.new(1992, 1, 1, 0, 2, 0)
      end
    end

    describe "#ms", mock_time: true do
      it "returns current ms since unix epoch" do
        expect(Util.nanos).to eq 694224000000000000
      end
    end

  end
end
