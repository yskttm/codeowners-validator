# frozen_string_literal: true

require "spec_helper"

RSpec.describe CodeownersValidator::SortPatterns do
  def sort(content)
    described_class.new(nil).sort(content)
  end

  context "already sorted" do
    it "returns content unchanged" do
      content = <<~CODEOWNERS
        #
        # header comment
        #

        /aaa @owner-a
        /bbb @owner-b
        /ccc @owner-c
      CODEOWNERS
      expect(sort(content)).to eq(content)
    end
  end

  context "unsorted patterns" do
    it "sorts all patterns globally by path" do
      input = <<~CODEOWNERS
        #
        # header
        #

        /zzz @owner-z
        /aaa @owner-a
        /mmm @owner-m
      CODEOWNERS
      expected = <<~CODEOWNERS
        #
        # header
        #

        /aaa @owner-a
        /mmm @owner-m
        /zzz @owner-z
      CODEOWNERS
      expect(sort(input)).to eq(expected)
    end
  end

  context "section comments between patterns" do
    it "keeps section comments with their following pattern and sorts globally" do
      input = <<~CODEOWNERS
        #
        # header
        #

        # section Z
        /zzz @owner-z
        /mmm @owner-m

        # section A
        /aaa @owner-a
        /bbb @owner-b
      CODEOWNERS
      expected = <<~CODEOWNERS
        #
        # header
        #

        # section A
        /aaa @owner-a
        /bbb @owner-b
        /mmm @owner-m
        # section Z
        /zzz @owner-z
      CODEOWNERS
      expect(sort(input)).to eq(expected)
    end
  end

  context "inline comment within patterns" do
    it "keeps the inline comment with its following pattern and sorts globally" do
      input = <<~CODEOWNERS
        #
        # header
        #

        /schema/foo @owner-a
        # inline comment
        /api/bar @owner-a
      CODEOWNERS
      expected = <<~CODEOWNERS
        #
        # header
        #

        # inline comment
        /api/bar @owner-a
        /schema/foo @owner-a
      CODEOWNERS
      expect(sort(input)).to eq(expected)
    end
  end

  context "comment before first pattern with no blank line between them" do
    it "keeps the comment with its following pattern and sorts globally" do
      input = "# hoge\n/zzz @owner-z\n/aaa @owner-a\n"
      expected = "/aaa @owner-a\n# hoge\n/zzz @owner-z\n"
      expect(sort(input)).to eq(expected)
    end
  end

  context "comment separated from its pattern by a blank line" do
    it "keeps the comment with the next pattern even across a blank line" do
      input = <<~CODEOWNERS
        #
        # header
        #

        /zzz @owner-z
        ## a comment

        /aaa @owner-a
      CODEOWNERS
      expected = <<~CODEOWNERS
        #
        # header
        #

        ## a comment
        /aaa @owner-a
        /zzz @owner-z
      CODEOWNERS
      expect(sort(input)).to eq(expected)
    end
  end

  context "file header only (no patterns)" do
    it "returns content unchanged" do
      content = <<~CODEOWNERS
        #
        # header comment
        #
      CODEOWNERS
      expect(sort(content)).to eq(content)
    end
  end

  context "no file header" do
    it "sorts patterns without a header" do
      input = "/zzz @owner-z\n/aaa @owner-a\n"
      expected = "/aaa @owner-a\n/zzz @owner-z\n"
      expect(sort(input)).to eq(expected)
    end
  end

  context "file ending without trailing newline" do
    it "preserves the lack of trailing newline" do
      input = "/zzz @owner-z\n/aaa @owner-a"
      expected = "/aaa @owner-a\n/zzz @owner-z"
      expect(sort(input)).to eq(expected)
    end
  end
end
