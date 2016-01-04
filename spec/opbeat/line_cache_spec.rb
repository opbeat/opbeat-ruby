require 'spec_helper'

module Opbeat
  RSpec.describe LineCache do

    let(:path) { "some/file.rb" }
    let(:lines) { %w{these are the lines} }

    describe ".all" do
      it "returns the lines of the file at path" do
        allow(File).to receive(:readlines) { lines }
        expect(LineCache.all path).to eq lines
      end
      it "rescues any exception" do
        allow(LineCache::CACHE).to receive(:[]) { nil }
        allow(File).to receive(:readlines).and_raise "BOOM"
        expect(LineCache.all path).to eq []
      end
      it "caches results" do
        allow(File).to receive(:readlines) { lines }.once
        LineCache.all path
        LineCache.all path
      end
    end

    describe ".find" do
      it "returns one line of the file at path" do
        allow(File).to receive(:readlines) { lines }.once
        allow(LineCache::CACHE).to receive(:[]) { nil }
        expect(LineCache.find path, 2).to eq "are"
      end
      it "is nil when less than 1" do
        expect(LineCache.find path, 0).to be_nil
      end
    end

  end
end
