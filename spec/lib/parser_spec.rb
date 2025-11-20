# frozen_string_literal: true

require "spec_helper"

RSpec.describe CodeownersValidator::Parser do
  describe "#parse" do
    it "ignores blank lines and comments" do
      lines = [
        "",
        " ",
        "# comment",
        "path @owner1",
      ]

      entries = described_class.new(lines).parse

      expect(entries.size).to eq(1)
      expect(entries.first.line_number).to eq(4)
    end

    it "parses inline comments" do
      lines = [
        "path @owner1 @owner2 # some comment",
      ]

      entries = described_class.new(lines).parse

      expect(entries.size).to eq(1)
      expect(entries.first.pattern).to eq("path")
      expect(entries.first.owners).to eq(["@owner1", "@owner2"])
      expect(entries.first.comment).to eq("some comment")
      expect(entries.first.line_number).to eq(1)
    end
  end
end
