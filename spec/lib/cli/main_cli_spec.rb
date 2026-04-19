# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe CodeownersValidator::MainCli do
  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      example.run
    end
  end

  def create_file(rel_path, content = "")
    path = File.join(@dir, rel_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
    path
  end

  def run(*args)
    described_class.new(args).run
  end

  context "unknown subcommand" do
    it "returns 1" do
      expect(run("unknown")).to eq(1)
    end
  end

  context "no subcommand" do
    it "returns 1" do
      expect(run).to eq(1)
    end
  end

  context "duplicate subcommand" do
    it "returns 0 when no duplicates" do
      path = create_file("CODEOWNERS", "/foo @owner\n")
      expect(run("duplicate", "-q", path)).to eq(0)
    end

    it "returns 1 when duplicates exist" do
      path = create_file("CODEOWNERS", "/foo @owner\n/foo @other\n")
      expect(run("duplicate", "-q", path)).to eq(1)
    end

    it "returns 1 when CODEOWNERS file not found" do
      expect(run("duplicate", "-q", File.join(@dir, "CODEOWNERS"))).to eq(1)
    end
  end

  context "ghost subcommand" do
    it "returns 0 when no ghost patterns" do
      FileUtils.touch(File.join(@dir, "foo.rb"))
      path = create_file("CODEOWNERS", "/foo.rb @owner\n")
      expect(run("ghost", "-q", path)).to eq(0)
    end

    it "returns 1 when ghost patterns exist" do
      path = create_file("CODEOWNERS", "/missing.rb @owner\n")
      expect(run("ghost", "-q", path)).to eq(1)
    end

    it "returns 1 when CODEOWNERS file not found" do
      expect(run("ghost", "-q", File.join(@dir, "CODEOWNERS"))).to eq(1)
    end
  end

  context "uncovered subcommand" do
    it "returns 0 when all files are covered" do
      FileUtils.touch(File.join(@dir, "foo.rb"))
      path = create_file("CODEOWNERS", "* @owner\n")
      expect(run("uncovered", "-q", path)).to eq(0)
    end

    it "returns 1 when uncovered files exist" do
      FileUtils.touch(File.join(@dir, "foo.rb"))
      path = create_file("CODEOWNERS", "")
      expect(run("uncovered", "-q", path)).to eq(1)
    end

    it "returns 1 when CODEOWNERS file not found" do
      expect(run("uncovered", "-q", File.join(@dir, "CODEOWNERS"))).to eq(1)
    end
  end
end
