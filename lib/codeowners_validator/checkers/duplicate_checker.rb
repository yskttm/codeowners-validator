# frozen_string_literal: true

module CodeownersValidator
  class DuplicateChecker
    Result = Data.define(:duplicates)

    def initialize(entries)
      @entries = entries
    end

    def run
      by_pattern = Hash.new { |h, k| h[k] = [] }

      @entries.each do |entry|
        by_pattern[entry.pattern] << entry
      end

      duplicates = by_pattern.select { |_, v| v.size > 1 }

      Result.new(duplicates: duplicates)
    end
  end
end
