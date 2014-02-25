class AddNewTransactionTypeShareForFree < ActiveRecord::Migration
  def up
    Category.find_all_by_name("housing").each do |category|
      
      # don't react if community id is nil
      if category.community

        listings = Listing.find_all_by_category_id(category.id)

        # create share_for_free if needed
        sff = ShareForFree.find_by_community_id(category.community_id)
        unless sff
          puts "Creating trans type ShareForFree for community #{category.community.domain}"
          sff = ShareForFree.create!(:community_id => category.community_id, :price_field => false, :sort_priority => -1)          
          create_translations_for(sff, category.community)
          CategoryTransactionType.create!(:category_id => category.id, :transaction_type_id => sff.id)
        else
          puts "Already found trans type ShareForFree for community #{category.community.domain}"
        end

        # loop all listings in that category
        listings.each do |listing|
          # Check if linked to sell services trans type
          # or if linked to non existing trans type (probably deleted by last migration)
          
          if listing.transaction_type.nil? || listing.transaction_type.class == Service
            puts "updating listing #{listing.id} to point to trans_type #{sff.id}"
            listing.update_column(:transaction_type_id, sff.id)
          end
        end
      end
    end
  end

    # Creates translations for new transaciton type
  def create_translations_for(trans_type, community)

    community.locales.each do |locale|
      if TransactionTypeTranslation.find_by_transaction_type_id_and_locale(trans_type.id, locale)
        puts "WARNING: #{locale} translation for trans_type.id #{trans_type.id} already exists"

      else 

        translated_name = I18n.t(trans_type.api_name, :locale => locale, :scope => ["admin", "transaction_types"])

        TransactionTypeTranslation.create(:locale => locale, :transaction_type_id => trans_type.id, 
          :name => translated_name)
      end
    end

  end

  def down
    raise  ActiveRecord::IrreversibleMigration, "Reverse migration not implemented"
  end
end
