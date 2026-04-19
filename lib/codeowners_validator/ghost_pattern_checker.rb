# frozen_string_literal: true

module CodeownersValidator
  class GhostPatternChecker
    Result = Data.define(:ghosts)

    def initialize(entries, repo_root)
      @entries = entries
      @repo_root = repo_root
    end

    def run
      ghosts = @entries.reject { |entry| matches_something?(entry.pattern) }
      Result.new(ghosts:)
    end

    private

    def matches_something?(pattern)
      if pattern.end_with?("/")
        Dir.exist?(File.join(@repo_root, pattern.delete_prefix("/").chomp("/")))
      else
        glob = if pattern.start_with?("/")
                 File.join(@repo_root, pattern.delete_prefix("/"))
               else
                 File.join(@repo_root, "**", pattern)
               end
        Dir.glob(glob).any?
      end
    end
  end
end
