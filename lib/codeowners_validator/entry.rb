# frozen_string_literal: true

module CodeownersValidator
  CodeownersEntry = Data.define(:raw, :pattern, :owners, :comment, :line_number)
end
