# frozen_string_literal: true

require_relative "parser"
require_relative "duplicate_checker"

module CodeownersValidator
  class Cli
    def initialize(codeowners_path, quiet: false)
      @codeowners_path = codeowners_path
      @quiet = quiet
    end

    def run
      return false unless codeowners_present?

      lines   = File.readlines(@codeowners_path, chomp: true)
      entries = Parser.new(lines).parse
      result  = DuplicateChecker.new(entries).run

      if !result.duplicates.empty?
        print_duplicates(result.duplicates)
        false
      else
        log "No duplicate CODEOWNERS entries found."
        true
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

    def print_duplicates(duplicates)
      return if @quiet

      puts "Duplicate CODEOWNERS entries detected:"

      duplicates.each do |pattern, entries|
        puts pattern
        entries.sort_by(&:line_number).each do |entry|
          owners_str   = entry.owners.join(" ")
          owners_label = owners_str.empty? ? "(no owners)" : owners_str
          puts "- #{owners_label} at lines #{entry.line_number}"
        end
      end

      puts "Total duplicate groups: #{duplicates.size}"
    end
  end
end
