# frozen_string_literal: true

module CodeownersValidator
  class SortPatterns
    def initialize(path)
      @path = path
    end

    def run
      original = File.read(@path)
      sorted = sort(original)
      File.write(@path, sorted) if sorted != original
    end

    def sort(content)
      lines = content.split("\n", -1)

      first_pattern_idx = lines.index { |l| !l.empty? && !l.start_with?("#") }
      return content if first_pattern_idx.nil?

      pre_pattern = lines[0...first_pattern_idx]
      last_blank_idx = pre_pattern.rindex(&:empty?)
      header = last_blank_idx ? lines[0..last_blank_idx] : []

      # ヘッダー後の全行をコメント付きエントリのグループとして解析する。
      # コメント行は直後のパターン行の説明として扱い、一緒に移動させる。
      body_start = last_blank_idx ? last_blank_idx + 1 : 0
      groups = build_groups(lines[body_start..])

      sorted_groups = groups.sort_by { |group| group.last.split.first }

      trailing = lines.last.empty? ? [""] : []

      (header + sorted_groups.flatten + trailing).join("\n")
    end

    private

    def build_groups(lines)
      groups = []
      pending_comments = []

      lines.each do |line|
        if line.empty?
          next
        elsif line.start_with?("#")
          pending_comments << line
        else
          groups << (pending_comments + [line])
          pending_comments = []
        end
      end

      groups
    end
  end
end
