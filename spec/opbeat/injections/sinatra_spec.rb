require 'spec_helper'
require 'sinatra'

module Opbeat
  RSpec.describe Injections::Sinatra do

    it "is installed" do
      reg = Opbeat::Injections.installed['Sinatra::Base']
      expect(reg).to_not be_nil
    end

  end
end
