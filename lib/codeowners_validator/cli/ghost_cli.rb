# frozen_string_literal: true

module CodeownersValidator
  class GhostCli
    def initialize(codeowners_path, quiet: false)
      @codeowners_path = codeowners_path
      @quiet = quiet
    end

    def run
      return false unless codeowners_present?

      repo_root = File.dirname(File.expand_path(@codeowners_path))
      lines = File.readlines(@codeowners_path, chomp: true)
      entries = Parser.new(lines).parse
      result = GhostPatternChecker.new(entries, repo_root).run

      if result.ghosts.empty?
        log "No ghost CODEOWNERS patterns found."
        true
      else
        print_ghosts(result.ghosts)
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

    def print_ghosts(ghosts)
      return if @quiet

      puts "Ghost CODEOWNERS patterns detected:"
      ghosts.each do |entry|
        owners_str = entry.owners.empty? ? "(no owners)" : entry.owners.join(" ")
        puts "#{entry.pattern} #{owners_str} at line #{entry.line_number}"
      end
      puts "Total ghost patterns: #{ghosts.size}"
    end
  end
end
