# frozen_string_literal: true

module CodeownersValidator
  CodeownersEntry = Data.define(:raw, :pattern, :owners, :comment, :line_number)

  class Parser
    def initialize(lines)
      @lines = lines
    end

    def parse
      @lines.each.with_index(1).with_object([]) do |(line, line_number), entries|
        stripped = line.strip

        next if stripped.empty? || stripped.start_with?("#")

        pattern, owners, comment = split_line(stripped)

        entries << CodeownersEntry.new(
          raw: stripped,
          pattern:,
          owners:,
          comment:,
          line_number:
        )
      end
    end

    private

    # Very simple splitter:
    #   "path @owner1 @owner2 # comment" =>
    #     pattern: "path"
    #     owners: ["@owner1", "@owner2"]
    #     comment: "comment" (without leading '# ')
    def split_line(stripped)
      main_part, comment_part = stripped.split("#", 2)
      main_tokens = main_part.strip.split

      pattern = main_tokens[0]
      owners  = main_tokens[1..] || []
      comment = comment_part&.strip

      [pattern, owners, comment]
    end
  end
end
