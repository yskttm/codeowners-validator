# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe CodeownersValidator::UncoveredFileChecker do
  let(:entry_class) { CodeownersValidator::CodeownersEntry }

  def make_entry(pattern, line_number: 1)
    entry_class.new(raw: pattern, pattern:, owners: ["@owner"], comment: nil, line_number:)
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

  def create_file(*path_parts)
    full_path = File.join(@repo_root, *path_parts)
    FileUtils.mkdir_p(File.dirname(full_path))
    FileUtils.touch(full_path)
  end

  context "exact file patterns" do
    it "returns no uncovered files when all files are matched" do
      create_file("app", "models", "user.rb")
      entries = [make_entry("/app/models/user.rb")]

      result = run(entries)

      expect(result.uncovered_files).to be_empty
    end

    it "returns uncovered files when a file has no matching pattern" do
      create_file("app", "models", "user.rb")
      entries = []

      result = run(entries)

      expect(result.uncovered_files).to eq(["app/models/user.rb"])
    end
  end

  context "directory patterns (trailing slash)" do
    it "returns no uncovered files when files are under the matched directory" do
      create_file("app", "models", "user.rb")
      create_file("app", "models", "post.rb")
      entries = [make_entry("/app/models/")]

      result = run(entries)

      expect(result.uncovered_files).to be_empty
    end

    it "returns uncovered files outside the matched directory" do
      create_file("app", "models", "user.rb")
      create_file("app", "controllers", "users_controller.rb")
      entries = [make_entry("/app/models/")]

      result = run(entries)

      expect(result.uncovered_files).to eq(["app/controllers/users_controller.rb"])
    end
  end

  context "wildcard patterns" do
    it "returns no uncovered files when the wildcard covers all files" do
      create_file("app", "models", "user.rb")
      create_file("app", "models", "post.rb")
      entries = [make_entry("/app/**/*.rb")]

      result = run(entries)

      expect(result.uncovered_files).to be_empty
    end

    it "returns uncovered files not matched by the wildcard" do
      create_file("app", "models", "user.rb")
      create_file("app", "config", "settings.yml")
      entries = [make_entry("/app/**/*.rb")]

      result = run(entries)

      expect(result.uncovered_files).to eq(["app/config/settings.yml"])
    end

    it "returns no uncovered files when extension-less wildcard covers all files" do
      create_file("app", "models", "user.rb")
      create_file("app", "config", "settings.yml")
      entries = [make_entry("/app/**/*")]

      result = run(entries)

      expect(result.uncovered_files).to be_empty
    end

    it "returns no uncovered files when /** covers all files including root-level and nested ones" do
      create_file("Gemfile")
      create_file("lib", "foo.rb")
      create_file("lib", "deep", "bar.rb")
      entries = [make_entry("/**")]

      result = run(entries)

      expect(result.uncovered_files).to be_empty
    end

    it "returns no uncovered files when /**/* covers all files including root-level ones" do
      create_file("Gemfile")
      create_file("lib", "foo.rb")
      create_file("lib", "deep", "bar.rb")
      entries = [make_entry("/**/*")]

      result = run(entries)

      expect(result.uncovered_files).to be_empty
    end

    it "returns no uncovered files when /logs/** covers files under the directory" do
      create_file("logs", "app.log")
      create_file("logs", "2024", "error.log")
      entries = [make_entry("/logs/**")]

      result = run(entries)

      expect(result.uncovered_files).to be_empty
    end

    it "returns no uncovered files when /logs/**/* covers files under the directory" do
      create_file("logs", "app.log")
      create_file("logs", "2024", "error.log")
      entries = [make_entry("/logs/**/*")]

      result = run(entries)

      expect(result.uncovered_files).to be_empty
    end
  end

  context "non-rooted patterns" do
    it "returns no uncovered files when a non-rooted pattern matches anywhere in the tree" do
      create_file("deep", "nested", "file.rb")
      entries = [make_entry("*.rb")]

      result = run(entries)

      expect(result.uncovered_files).to be_empty
    end
  end

  context "excluded paths" do
    it "ignores .git directory by default" do
      create_file(".git", "config")
      create_file("app", "main.rb")
      entries = [make_entry("/app/main.rb")]

      result = run(entries)

      expect(result.uncovered_files).to be_empty
    end
  end

  context "multiple patterns" do
    it "returns only files not covered by any pattern" do
      create_file("app", "models", "user.rb")
      create_file("app", "controllers", "users_controller.rb")
      create_file("config", "settings.yml")

      entries = [
        make_entry("/app/models/", line_number: 1),
        make_entry("/app/controllers/", line_number: 2),
      ]

      result = run(entries)

      expect(result.uncovered_files).to eq(["config/settings.yml"])
    end
  end
end
