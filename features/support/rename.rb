# features/support/twitter_formatter.rb
require 'rubygems'

# This is an example script, which can be used to rename large amount
# of steps. It's kind of a hack, since this is a Cucumber "formatter".
# However, it does its job pretty ok.
#
# Usage:
# 1) Add step-to-be-renamed and rename method to `replaces` hash
# 2) Run: cucumber features --format Rename::GivenListingRenamer

module Rename
  class GivenListingRenamer
    def initialize(step_mother, io, options)
      # We don't care about these - we're just twittering!
    end

    def replace_in_file(file_name, search, replace)
      text = File.read(file_name)
      File.open(file_name, "w") { |f| f.write(text.gsub(search, replace)) }
    end

    # /^there is (item|favor|housing) (offer|request) with title "([^"]*)"(?: from "([^"]*)")?(?: and with share type "([^"]*)")?(?: and with price "([^"]*)")?$/
    def rename1(keyword, category, type, title, author, share_type, price)
      new_category = case category
      when "item"
        "Items"
      when "favor"
        "Services"
      when "housing"
        "Spaces"
      end

      transaction_type = if share_type.present?
        transaction_type = if share_type == "sell" then "Selling"
        elsif share_type == "borrow" then "Requesting"
        elsif share_type == "offer" then "Selling services"
        elsif share_type == "lend" then "Lending"
        else
          "Requesting"
        end
      else
        if type == "offer" then
          "Selling services"
        else
          "Requesting"
        end
      end

      author_step = if author
        " from \"#{author}\""
      else
        ""
      end

      community ||= "test"

      %Q{#{keyword}there is a listing with title "#{title}"#{author_step} with category "#{new_category}" and with transaction type "#{transaction_type}"}
    end

    # /^there is rideshare (offer|request) from "([^"]*)" to "([^"]*)" by "([^"]*)"$/
    def rename_rideshare(keyword, type, origin, destination, author)
      new_category = "Services"

      transaction_type = if type == "offer" then
        "Selling services"
      else
        "Requesting"
      end

      author_step = if author
        " from \"#{author}\""
      else
        ""
      end

      community ||= "test"

      title = "#{origin} - #{destination}"

      %Q{#{keyword}there is a listing with title "#{title}"#{author_step} with category "#{new_category}" and with transaction type "#{transaction_type}"}
    end

    def step_name(keyword, step_match, status, source_indent, background, file_colon_line)
      replaces = {
        %Q{/^there is (item|favor|housing) (offer|request) with title "([^"]*)"(?: from "([^"]*)")?(?: and with share type "([^"]*)")?(?: and with price "([^"]*)")?$/} => :rename1,
        %Q{/^there is rideshare (offer|request) from "([^"]*)" to "([^"]*)" by "([^"]*)"$/} => :rename_rideshare
      }.select do |source, replace_method|
        step_match && step_match.step_definition && step_match.step_definition.regexp_source == source
      end.each do |source, replace_method|
        search = "#{keyword}#{step_match.format_args}"
        replace = self.send replace_method, *[keyword, step_match.args].flatten

        file_name, _ = file_colon_line.split(":")
        path = "/Users/mikko/Documents/Projects/sharetribe/sharetribe/#{file_name}"

        replace_in_file(file_name, search, replace)

        puts "Replaced #{search} from #{file_name}"
      end
    end
  end
end
