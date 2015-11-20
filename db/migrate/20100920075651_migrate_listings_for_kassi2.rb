# encoding: utf-8

class MigrateListingsForKassi2 < ActiveRecord::Migration
  def self.up
    unclear_cases_count = 0
    unknown_categories_count = 0
    valid_listings_count = 0
    invalid_listings_count = 0



    say "***** THIS MIGRATION REQUIRES MANUAL WORK ALSO, PLEASE PAY ATTENTION! ******"

    say "Going through all the listings with listing_type.nil?"
    say "Those attributes that cannot be set automatically are listed to 'value_other'.", true
    say ""
    say "It is HIGHLY RECOMMENDED to change the 'set_property :delta => true' to false in listing.rb before running this migration, since delta indexing makes it really slow if there are lot of listings."
    say "Just remember to turn it back on afterwards!", true

    Listing.all.each do |listing|
      listing_updated_at = listing.updated_at
      if listing.listing_type.nil?
        case listing.category
  # Offers
        when "sell"
          listing.listing_type = "offer"
          listing.category = "item"
          listing.share_type_attributes = ["sell"]
        when "give"
          listing.listing_type = "offer"
          listing.category = "item"
          listing.share_type_attributes = ["give_away"]
        when "found"
          listing.listing_type = "offer"
          listing.category = "item"
          #listing.share_type_attributes = ["give_away"]
          listing.tag_list = "löytötavara, löytynyt, found"
          #listing.value_other = "share_type"
          # TODO: Should maybe be done without share type
        when "for_rent"
          listing.listing_type = "offer"
          listing.category = "housing"
          listing.share_type_attributes = ["rent_out"]
  # Requests
        when "buy"
          listing.listing_type = "request"
          listing.category = "item"
          listing.share_type_attributes = ["buy"]
        when "borrow_items"
          listing.listing_type = "request"
          listing.category = "item"
          listing.share_type_attributes = ["borrow"]
        when "lost"
          listing.listing_type = "request"
          listing.category = "item"
          #listing.share_type_attributes = ["trade"]
          listing.tag_list = "löytötavara, kadonnut, lost"
          #listing.value_other = "share_type"
        when "favors"
          listing.listing_type = "request"
          listing.category = "favor"
        when "looking_for_apartment"
          listing.listing_type = "request"
          listing.category = "housing"
          listing.share_type_attributes = ["rent"]
  # Harder cases
        when "groups"
          listing.category = "favor"
          listing.tag_list = "porukkahaku, group activities"
          listing.value_other = "listing_type"
          unclear_cases_count += 1
        when "others"
          listing.value_other = "listing_type, category, share_type, tags"
          unclear_cases_count += 1
        when "rides"
          listing.category = "rideshare"
          listing.value_other = "listing_type, origin, destination"
          unclear_cases_count += 1
        when "roommates"
          listing.category = "housing"
          listing.value_other = "listing_type, share_type"
          unclear_cases_count += 1
        when "temporary_accommodation"
          listing.category = "housing"
          listing.share_type_attributes = ["temporary_accommodation"]
          listing.value_other = "listing_type"
          unclear_cases_count += 1
        when /rideshare|favor|item|housing/
          # These are the new categories, so probably the listing is either migrated already or made with the new UI
          # However the listing_type was nil, so mark it to be checked
          listing.value_other = "listing_type"
          unclear_cases_count += 1
        else
          unknown_categories_count += 1
          say "ENCOUNTERED AN UNKNOWN CATEGORY: (#{listing.id}) #{listing.title} (with category: #{listing.category})"
          listing.value_other = "CHECK ALL FIELDS!"
        end

        # These are common to every listing that was modified

        # set 'open' based on 'status'
        if listing.status == "open"
          listing.open = 1
        elsif listing.status == "closed"
          listing.open = 0
        else
          say  "ENCOUNTERED A LISTING WITH UNKNOWN STATUS:(#{listing.id}) #{listing.title} (with status: #{listing.status})"
        end

        # set valid_until based on good_thru
        if listing.good_thru && listing.valid_until.nil?
          listing.valid_until = listing.good_thru
          listing.set_valid_until_time
        end

        # set description based on content
        if !listing.content.nil? && listing.description.nil?
          listing.description = listing.content
        end



        if listing.valid?
          valid_listings_count += 1
        else
          invalid_listings_count += 1
        end
        # save without validations, because automatic modifications may have left some listings incomplete
        listing.save(:validate => false)

        # set original updated_at date
        listing.update_attribute("updated_at", listing_updated_at)
        print "."
        STDOUT.flush
      end
    end

    say ""
    say "Finished automatic modifications to listings. Modified #{valid_listings_count + invalid_listings_count} listings out of #{Listing.count}."
    say "#{valid_listings_count} of the modified are now valid. #{invalid_listings_count} are invalid and need manual checking."
    say "There were #{unclear_cases_count} listings with unclear listing_type (e.g. all rides) so those need to be set manually."
    say "There were also #{unknown_categories_count} listings with unknown categories, so check those manually too" if unknown_categories_count > 0
    say "NOTICE: IF THE MANUAL CHANGES MENTIONED ABOVE ARE NOT MADE, THE LISTINGS WON'T BE VISIBLE IN THE UI!"
    say "Please check through the column 'value_other' in DB to find out which attributes need manual fixin on each listing.", true
  end

  def self.down
    # raise  ActiveRecord::IrreversibleMigration, "This migration adds data to many places\
    #   and it's hard to reverse only those changes. However, this migration doesn't change the\
    #   database schema so if you want to go backwards, you can remove this IrreversibleMigration quite safely."
  end
end
