# frozen_string_literal: true

require "optparse"

module CodeownersValidator
  class MainCli
    def initialize(argv)
      @argv = argv.dup
    end

    def run
      subcommand = @argv.shift
      case subcommand
      when "duplicate" then run_subcommand(DuplicateCli)
      when "ghost"     then run_subcommand(GhostCli)
      when "uncovered" then run_subcommand(UncoveredCli)
      else
        warn usage
        1
      end
    end

    private

    def run_subcommand(cli_class)
      options = parse_options
      path = codeowners_path
      cli_class.new(path, quiet: options[:quiet]).run ? 0 : 1
    end

    def parse_options
      options = {quiet: false}
      OptionParser.new do |opts|
        opts.on("-q", "--quiet", "Suppress output") { options[:quiet] = true }
      end.parse!(@argv)
      options
    end

    def codeowners_path
      @argv.shift || File.expand_path("CODEOWNERS", Dir.pwd)
    end

    def usage
      <<~USAGE
        Usage: codeowners-validator <subcommand> [options] [CODEOWNERS_PATH]

        Subcommands:
          duplicate   Check for duplicate patterns
          ghost       Check for patterns that match no files
          uncovered   Check for files not covered by any pattern

        Options:
          -q, --quiet   Suppress output
      USAGE
    end
  end
end
