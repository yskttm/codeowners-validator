# frozen_string_literal: true

require "spec_helper"

RSpec.describe CodeownersValidator::DuplicateLineChecker do
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
      entry_class.new(raw: "path @owner1", pattern: "path", owners: ["@owner1"], comment: nil, line_number: 5),
    ]

    result = described_class.new(entries).run

    expect(result.duplicates).not_to be_empty
    expect(result.duplicates.size).to eq(1)
    group = result.duplicates.first
    expect(group.map(&:line_number)).to match_array([1, 5])
  end
end
