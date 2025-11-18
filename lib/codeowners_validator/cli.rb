# frozen_string_literal: true

require_relative "parser"
require_relative "duplicate_line_checker"

module CodeownersValidator
  class Cli
    def initialize(codeowners_path)
      @codeowners_path = codeowners_path
    end

    def run
      unless File.file?(@codeowners_path)
        puts "CODEOWNERS file not found at #{@codeowners_path}"
        return false
      end

      lines   = File.readlines(@codeowners_path, chomp: true)
      entries = Parser.new(lines).parse
      result  = DuplicateLineChecker.new(entries).run

      if !result.duplicates.empty?
        print_duplicates(result.duplicates)
        false
      else
        puts "No duplicate CODEOWNERS entries found."
        true
      end
    end

    private

    def print_duplicates(duplicates)
      puts "Duplicate CODEOWNERS entries detected:"

      duplicates.each do |group|
        pattern = group.first.pattern

        puts pattern
        group.sort_by(&:line_number).each do |entry|
          owners_str   = entry.owners.join(" ")
          owners_label = owners_str.empty? ? "(no owners)" : owners_str
          puts "- #{owners_label} at lines #{entry.line_number}"
        end
      end

      puts "Total duplicate groups: #{duplicates.size}"
    end
  end
end
