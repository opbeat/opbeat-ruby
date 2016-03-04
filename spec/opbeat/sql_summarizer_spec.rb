require 'spec_helper'

module Opbeat
  RSpec.describe SqlSummarizer do
    let(:config) { Configuration.new }

    subject { SqlSummarizer.new(config) }

    it 'summarizes selects' do
      expect(subject.signature_for("SELECT CAST(SERVERPROPERTY('ProductVersion') AS varchar)")).to eq('SQL')
    end

    it 'summarizes selects from table' do
      expect(subject.signature_for("SELECT * FROM table")).to eq('SELECT FROM table')
    end

    it 'summarizes selects from table with columns' do
      expect(subject.signature_for("SELECT a, b FROM table")).to eq('SELECT FROM table')
    end

    it 'summarizes inserts' do
      expect(subject.signature_for("INSERT INTO table (a, b) VALUES ('A','B')")).to eq('INSERT INTO table')
    end

    it 'summarizes updates' do
      expect(subject.signature_for("UPDATE table SET a = 'B' WHERE b = 'B'")).to eq('UPDATE table')
    end

    it 'summarizes deletes' do
      expect(subject.signature_for("DELETE FROM table WHERE b = 'B'")).to eq('DELETE FROM table')
    end
  end
end
