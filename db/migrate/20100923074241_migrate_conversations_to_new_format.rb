class Reservation < Conversation
end

class FavorRequest < Conversation
end

class Favor < ApplicationRecord
  belongs_to :owner, :class_name => "Person", :foreign_key => "owner_id"
end

class Item < ApplicationRecord
  belongs_to :owner, :class_name => "Person", :foreign_key => "owner_id"
end

class KassiEventParticipation < ApplicationRecord
  belongs_to :person
  belongs_to :kassi_event
end

class KassiEvent < ApplicationRecord
  has_many :person_comments
  has_many :kassi_event_participations
  has_many :participants, :through => :kassi_event_participations, :source => :person
  #belongs_to :eventable, :polymorphic => true
end

class PersonComment < ApplicationRecord
end

class PersonConversation < ApplicationRecord
  belongs_to :conversation
  belongs_to :person
end

class MigrateConversationsToNewFormat < ActiveRecord::Migration
  def self.up

    say  "Looping through all the #{PersonConversation.count} person_conversations and change them to participations"
    PersonConversation.all.each do |pc|
      participation = Participation.new({:person_id => pc.person_id,
                        :conversation_id => pc.conversation_id,
                        :is_read => pc.is_read,
                        :created_at => pc.created_at,
                        :last_sent_at => pc.last_sent_at,
                        :last_received_at => pc.last_received_at,
                        :feedback_skipped => false})
      participation.save!
      participation.update_attribute("updated_at", pc.updated_at)

      print "."; STDOUT.flush
    end
    puts ""

    say "Looping through all the #{KassiEvent.count} kassi_events"
    # create testimonials and conversations with two a message that explains it has been automatically created
    # take care that no emails are sent and that generated messages are marked as read

    KassiEvent.all.each do |ke|

      #check if conversation and create if not. if exists already mark status accepted.
      conversation = nil

      case ke.eventable_type
      when "Favor"
        #find the favor
        favor = Favor.find(ke.eventable_id)
        # find the listing that is made from the favor by the earlier migration
        listing = Listing.where(:title => favor.title, :author_id => favor.owner_id, :description => favor.description).first
        # Create conversation
        conversation = Conversation.new(:participants => ke.participants,
                         :title => favor.title,
                         :status => "accepted",
                         :listing => listing,
                         :created_at => favor.created_at,
                         :messages => [Message.new(:sender => ((ke.participants.first == favor.owner) ? ke.participants.last : ke.participants.first),
                                                   :content => "Auto-generated message by Kassi - Kassin automaattisesti luoma viesti.",
                                                   :created_at => favor.created_at)])

        conversation.save!
        conversation.participations.each{ |p| p.update_attribute(:is_read, true)}
        conversation.update_attribute("updated_at", listing.created_at)
      when "Item"
        #find the time
        item = Item.find(ke.eventable_id)
        # find the listing that is made from the item by the earlier migration
        listing = Listing.where(:title => item.title, :author_id => item.owner_id, :description => item.description).first
        # Create conversation
        conversation = Conversation.new(:participants => ke.participants,
                           :title => item.title,
                           :status => "accepted",
                           :listing => listing,
                           :created_at => item.created_at,
                           :messages => [Message.new(:sender => ((ke.participants.first == item.owner) ? ke.participants.last : ke.participants.first),
                                                     :content => "Auto-generated message by Kassi - Kassin automaattisesti luoma viesti.",
                                                     :created_at => item.created_at)])


        conversation.save!
        conversation.participations.each{ |p| p.update_attribute(:is_read, true)}
        conversation.update_attribute("updated_at", listing.created_at)
      when "Listing"
        listing = Listing.find(ke.eventable_id)
        # Maybe need to create a conversation
        possible_conversations = Conversation.where(listing_id: ke.eventable_id)
        #puts "Number of matching conversations: #{possible_conversations.count}"

        # pick the conversation with the right participants
        possible_conversations.reject!{|conv| not (ke.participants.all? {|part| conv.participants.include?(part)} ) }

        if possible_conversations.count > 0
          #if there are still many conversations between these people, just pick the first one
          conversation = possible_conversations.first
          conversation.status = "accepted"
          conversation.save!
        else
          # create conversation
          conversation = Conversation.new(:participants => ke.participants,
                           :title => listing.title,
                           :status => "accepted",
                           :listing => listing,
                           :created_at => listing.created_at,
                           :messages => [Message.new(:sender => ((ke.participants.first == listing.author) ? ke.participants.last : ke.participants.first),
                                                     :content => "Auto-generated message by Kassi - Kassin automaattisesti luoma viesti.",
                                                     :created_at => listing.created_at)])
          conversation.save!
          conversation.participations.each{ |p| p.update_attribute(:is_read, true)}
          conversation.update_attribute("updated_at", listing.created_at)
        end


      when "FavorRequest"
        # use existing conversation
        conversation = Conversation.find(ke.eventable_id)
        conversation.status = "accepted"
        conversation.save!
      when "Reservation"
        # use existing conversation
        conversation = Conversation.find(ke.eventable_id)
        conversation.status = "accepted"
        conversation.save!
      else
        say "DETECTED A KASSI EVENT (id: #{ke.id}) WITH UNKNOWN EVENTABLE_TYPE: #{ke.eventable_type}"
        say "Ignoring that event and continuing", true
      end

      unless conversation.nil?
        ke.person_comments.each do |person_comment|
          # find the right participation to attach this testimonial
          participation = Participation.where(:conversation_id => conversation.id, :person_id => person_comment.author_id).first
          # create the testimonial based on the PersonComment
          testimonial = Testimonial.new(:grade => person_comment.grade,
                          :text => person_comment.text_content,
                          :author_id => person_comment.author_id,
                          :created_at => person_comment.created_at,
                          :participation => participation)
          if testimonial.participation.nil?
            say "Created a testimonial without participation (id: #{testimonial.id})!"
            say "check DB manually", true
          end
          testimonial.save!
          testimonial.update_attribute("updated_at", person_comment.updated_at)
        end
        print "."; STDOUT.flush
      else
        say "Could NOT find or create a conversation for a KassiEvent (id: #{ke.id}, eventable type: #{ke.eventable_type})"
        say "Skipping that", true
      end
    end
    puts ""

    #say "Finally removing the column 'type' from table conversations."
    remove_column :conversations, :type
  end

  def self.down
    raise  ActiveRecord::IrreversibleMigration, "NOTE: ROLLING BACK OVER THIS MIGRATION ONLY ROLLS BACK THE CHANGES IN THE SCHEMA!\
    The data made by the migration is not deleted by this rollback! \
    If you are sure you want to rollback, remove this 'raise IreversibleMigration'."

    add_column :conversations, :type, :string

  end
end
