# frozen_string_literal: true

require "spec_helper"

RSpec.describe CodeownersValidator::DuplicateChecker do
  let(:entry_class) { CodeownersValidator::CodeownersEntry }

  it "returns no duplicates when all lines are unique" do
    entries = [
      entry_class.new(raw: "path @owner1", pattern: "path", owners: ["@owner1"], comment: nil, line_number: 1),
      entry_class.new(raw: "other @owner2", pattern: "other", owners: ["@owner2"], comment: nil, line_number: 2),
    ]

    result = described_class.new(entries).run

    expect(result.duplicates).to be_empty
  end

  it "returns duplicates when the same raw line appears multiple times" do
    entries = [
      entry_class.new(raw: "path @owner1", pattern: "path", owners: ["@owner1"], comment: nil, line_number: 1),
      entry_class.new(raw: "path2 @owner2", pattern: "path2", owners: ["@owner2"], comment: nil, line_number: 2),
      entry_class.new(raw: "path @owner3 @owner4", pattern: "path", owners: ["@owner3", "@owner4"], comment: "comment", line_number: 3),
    ]

    result = described_class.new(entries).run

    expect(result.duplicates.size).to eq(1)
    expect(result.duplicates["path"].size).to eq(2)
    expect(result.duplicates["path"].map(&:line_number)).to match_array([1, 3])
    expect(result.duplicates["path"].map(&:owners)).to match_array([["@owner1"], ["@owner3", "@owner4"]])
    expect(result.duplicates["path"].map(&:comment)).to match_array([nil, "comment"])
  end
end
