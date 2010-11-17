class Reservation < Conversation
end

class FavorRequest < Conversation
end

class Favor < ActiveRecord::Base
  belongs_to :owner, :class_name => "Person", :foreign_key => "owner_id"
end

class Item < ActiveRecord::Base
  belongs_to :owner, :class_name => "Person", :foreign_key => "owner_id"
end

class KassiEventParticipation < ActiveRecord::Base
  belongs_to :person
  belongs_to :kassi_event
end

class KassiEvent < ActiveRecord::Base
  has_many :person_comments
  has_many :kassi_event_participations
  has_many :participants, :through => :kassi_event_participations, :source => :person
  #belongs_to :eventable, :polymorphic => true
end

class ItemReservation < ActiveRecord::Base
end

class FixItemAndFavorRelatedTestimonials < ActiveRecord::Migration
  def self.up
    
    # Loop through the old KassiEvents again (as done in 20100923074241_migrate_conversations_to_new_format.rb)
    # This time we remember to put the listing id in the conversation
    
    say "Looping through all the old Kassi Events and fixing those where conversation lacks listing.id"
    KassiEvent.all.each do |ke|
    
      case ke.eventable_type
      when "FavorRequest"

        # use existing conversation
        conversation = Conversation.find(ke.eventable_id)
        
        favor = Favor.find(conversation.favor_id)
         # find the listing that is made in earlier migration
        listing = Listing.where(:title => favor.title, :author_id => favor.owner_id, :description => favor.description).first
        
        puts "Will change the li of conv #{conversation.id} to #{listing.id}"
        conversation.listing_id = listing.id
        conversation.save!
      when "Reservation"
        # use existing conversation
        conversation = Conversation.find(ke.eventable_id)
        
        res = ItemReservation.where(:reservation_id => conversation.id).first
        item = Item.find(res.item_id)
        
        
         # find the listing that is made in earlier migration
        listing = Listing.where(:title => item.title, :author_id => item.owner_id, :description => item.description).first
        
        puts "Will change the li of conv #{conversation.id} to #{listing.id}, when item id is #{item.id} and title #{item.title} and listing title #{listing.title}"
        conversation.listing_id = listing.id
        conversation.save! 
      end
    end
  end

  def self.down
    say "Removing the listing references added by this migration is not implemented. Rolling back this one does nothing."
  end
end
