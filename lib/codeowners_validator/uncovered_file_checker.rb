# frozen_string_literal: true

module CodeownersValidator
  class UncoveredFileChecker
    Result = Data.define(:uncovered_files)

    EXCLUDED_DIRS = %w[.git].freeze
    FNMATCH_FLAGS = File::FNM_PATHNAME | File::FNM_DOTMATCH

    def initialize(entries, repo_root)
      @entries = entries
      @repo_root = repo_root
    end

    def run
      all_files = Dir.glob("**/*", base: @repo_root).select do |path|
        File.file?(File.join(@repo_root, path)) && !excluded?(path)
      end

      uncovered = all_files.reject { |file| covered?(file) }
      Result.new(uncovered_files: uncovered.sort)
    end

    private

    def excluded?(path)
      EXCLUDED_DIRS.any? { |dir| path.start_with?("#{dir}/") }
    end

    def covered?(file_path)
      @entries.any? { |entry| matches?(file_path, entry.pattern) }
    end

    def matches?(file_path, pattern)
      if pattern.end_with?("/")
        # ディレクトリパターン: 配下の全ファイルにマッチ
        File.fnmatch("#{pattern.delete_prefix('/')}**", file_path, FNMATCH_FLAGS)
      elsif pattern.start_with?("/")
        # ルート固定パターン。
        # FNM_PATHNAME では ** 単体が / を跨がないため、** 終端のパターンは **/* も試みる
        glob = pattern.delete_prefix("/")
        File.fnmatch(glob, file_path, FNMATCH_FLAGS) ||
          (glob.end_with?("**") && File.fnmatch("#{glob}/*", file_path, FNMATCH_FLAGS))
      else
        # 非ルートパターン: ツリー内の任意の深さにマッチ
        File.fnmatch(pattern, file_path, FNMATCH_FLAGS) ||
          File.fnmatch("**/#{pattern}", file_path, FNMATCH_FLAGS)
      end
    end
  end
end
