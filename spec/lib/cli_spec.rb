# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe CodeownersValidator::Cli do
  def run_with_tempfile(content)
    file = Tempfile.new("codeowners")
    file.write(content)
    file.rewind

    cli = described_class.new(file.path)
    result = cli.run

    file.close!

    result
  end

  it "returns true when there are no duplicates" do
    content = <<~CODEOWNERS
      # comment
      path @owner1
      other @owner2
    CODEOWNERS

    result = run_with_tempfile(content)

    expect(result).to eq(true)
  end

  it "returns false when duplicates are present" do
    content = <<~CODEOWNERS
      path @owner1
      other @owner2
      path @owner1
    CODEOWNERS

    result = run_with_tempfile(content)

    expect(result).to eq(false)
  end
end
