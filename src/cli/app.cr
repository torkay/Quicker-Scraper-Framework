require "./commands/scrape_command"

module Scraper
  module CLI
    class App
      COMMANDS = {
        "scrape" => ->ScrapeCommand.run(Array(String)),
      }

      def self.run(args : Array(String))
        if args.empty? || args[0] == "--help" || args[0] == "-h"
          print_usage
          return
        end

        command = args[0]
        remaining = args[1..]

        handler = COMMANDS[command]?
        if handler
          handler.call(remaining)
        else
          STDERR.puts "Unknown command: #{command}"
          print_usage
          exit 1
        end
      end

      private def self.print_usage
        puts "Generic Scraper Framework v#{GenericScraper::VERSION}"
        puts ""
        puts "Usage: scraper <command> [options]"
        puts ""
        puts "Commands:"
        puts "  scrape    Run a scrape job for a vendor"
        puts ""
        puts "Options:"
        puts "  -h, --help    Show this help"
      end
    end
  end
end
