# frozen_string_literal: true

require_relative "entry"

module CodeownersValidator
  class DuplicateLineChecker
    Result = Data.define(:duplicates)

    def initialize(entries)
      @entries = entries
    end

    def run
      by_pattern = Hash.new { |h, k| h[k] = [] }

      @entries.each do |entry|
        by_pattern[entry.pattern] << entry
      end

      duplicates = by_pattern.values.select { |group| group.size > 1 }

      Result.new(duplicates: duplicates)
    end
  end
end
