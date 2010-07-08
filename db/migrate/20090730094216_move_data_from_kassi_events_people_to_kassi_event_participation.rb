class MoveDataFromKassiEventsPeopleToKassiEventParticipation < ActiveRecord::Migration
  def self.up
    KassiEvent.all.each do |event|
      event.people.each do |person|
        if event.realizer_id == person.id
          role = "provider"
        elsif event.receiver_id == person.id
          role = "requester"
        else  
          role = "none"
        end
        KassiEventParticipation.create(:person_id => person.id, 
                                       :kassi_event_id => event.id, 
                                       :role => role)
      end  
    end
  end

  def self.down
    KassiEventParticipation.all.each do |kep|
      kep.destroy
    end  
  end
end
