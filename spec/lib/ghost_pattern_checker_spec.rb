# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe CodeownersValidator::GhostPatternChecker do
  let(:entry_class) { CodeownersValidator::CodeownersEntry }

  def make_entry(pattern, line_number: 1)
    entry_class.new(raw: pattern, pattern:, owners: [], comment: nil, line_number:)
  end

  around do |example|
    Dir.mktmpdir do |repo_root|
      @repo_root = repo_root
      example.run
    end
  end

  def run(entries)
    described_class.new(entries, @repo_root).run
  end

  context "exact file patterns" do
    it "returns no ghosts when the file exists" do
      FileUtils.mkdir_p(File.join(@repo_root, "app", "models"))
      FileUtils.touch(File.join(@repo_root, "app", "models", "user.rb"))
      entries = [make_entry("/app/models/user.rb")]

      result = run(entries)

      expect(result.ghosts).to be_empty
    end

    it "returns ghost when the file does not exist" do
      entries = [make_entry("/app/models/user.rb")]

      result = run(entries)

      expect(result.ghosts.map(&:pattern)).to eq(["/app/models/user.rb"])
    end
  end

  context "directory patterns (trailing slash)" do
    it "returns no ghosts when the directory exists" do
      FileUtils.mkdir_p(File.join(@repo_root, "app", "models"))
      entries = [make_entry("/app/models/")]

      result = run(entries)

      expect(result.ghosts).to be_empty
    end

    it "returns ghost when the directory does not exist" do
      entries = [make_entry("/app/models/")]

      result = run(entries)

      expect(result.ghosts.map(&:pattern)).to eq(["/app/models/"])
    end
  end

  context "wildcard patterns" do
    it "returns no ghosts when the pattern matches at least one file" do
      FileUtils.mkdir_p(File.join(@repo_root, "app", "models"))
      FileUtils.touch(File.join(@repo_root, "app", "models", "user.rb"))
      entries = [make_entry("/app/**/*.rb")]

      result = run(entries)

      expect(result.ghosts).to be_empty
    end

    it "returns ghost when the pattern matches nothing" do
      entries = [make_entry("/app/**/*.rb")]

      result = run(entries)

      expect(result.ghosts.map(&:pattern)).to eq(["/app/**/*.rb"])
    end

    it "returns no ghosts when the extension-less wildcard matches a file" do
      FileUtils.mkdir_p(File.join(@repo_root, "app", "models"))
      FileUtils.touch(File.join(@repo_root, "app", "models", "user.rb"))
      entries = [make_entry("/app/**/*")]

      result = run(entries)

      expect(result.ghosts).to be_empty
    end

    it "returns ghost when the extension-less wildcard matches nothing" do
      entries = [make_entry("/app/**/*")]

      result = run(entries)

      expect(result.ghosts.map(&:pattern)).to eq(["/app/**/*"])
    end
  end

  context "non-rooted patterns" do
    it "returns no ghosts when the pattern matches a file anywhere in the tree" do
      FileUtils.mkdir_p(File.join(@repo_root, "deep", "nested"))
      FileUtils.touch(File.join(@repo_root, "deep", "nested", "file.rb"))
      entries = [make_entry("*.rb")]

      result = run(entries)

      expect(result.ghosts).to be_empty
    end

    it "returns ghost when the pattern matches nothing" do
      entries = [make_entry("*.rb")]

      result = run(entries)

      expect(result.ghosts.map(&:pattern)).to eq(["*.rb"])
    end
  end

  context "mixed entries" do
    it "returns only the ghost entries" do
      FileUtils.mkdir_p(File.join(@repo_root, "app"))
      FileUtils.touch(File.join(@repo_root, "app", "main.rb"))

      entries = [
        make_entry("/app/main.rb", line_number: 1),
        make_entry("/missing/path.rb", line_number: 2),
        make_entry("/also/missing.rb", line_number: 3),
      ]

      result = run(entries)

      expect(result.ghosts.map(&:pattern)).to eq(["/missing/path.rb", "/also/missing.rb"])
    end
  end
end
