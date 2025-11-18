# frozen_string_literal: true

require "spec_helper"

RSpec.describe CodeownersValidator::Parser do
  describe "#parse" do
    it "ignores blank lines and comments" do
      lines = [
        "",
        "# comment",
        "path @owner1",
      ]

      entries = described_class.new(lines).parse

      expect(entries.size).to eq(1)
      entry = entries.first
      expect(entry.pattern).to eq("path")
      expect(entry.owners).to eq(["@owner1"])
      expect(entry.comment).to be_nil
      expect(entry.line_number).to eq(3)
    end

    it "parses inline comments" do
      lines = [
        "path @owner1 @owner2 # some comment",
      ]

      entry = described_class.new(lines).parse.first

      expect(entry.pattern).to eq("path")
      expect(entry.owners).to eq(["@owner1", "@owner2"])
      expect(entry.comment).to eq("some comment")
    end
  end
end
