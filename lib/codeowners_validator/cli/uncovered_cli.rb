# frozen_string_literal: true

module CodeownersValidator
  class UncoveredCli
    def initialize(codeowners_path, quiet: false)
      @codeowners_path = codeowners_path
      @quiet = quiet
    end

    def run
      return false unless codeowners_present?

      repo_root = File.dirname(File.expand_path(@codeowners_path))
      lines = File.readlines(@codeowners_path, chomp: true)
      entries = Parser.new(lines).parse
      result = UncoveredFileChecker.new(entries, repo_root).run

      if result.uncovered_files.empty?
        log "No uncovered files found."
        true
      else
        print_uncovered(result.uncovered_files)
        false
      end
    end

    private

    def codeowners_present?
      return true if File.file?(@codeowners_path)

      log "CODEOWNERS file not found at #{@codeowners_path}"
      false
    end

    def log(message)
      puts message unless @quiet
    end

    def print_uncovered(files)
      return if @quiet

      puts "Uncovered files detected:"
      files.each { |f| puts "- #{f}" }
      puts "Total uncovered files: #{files.size}"
    end
  end
end
