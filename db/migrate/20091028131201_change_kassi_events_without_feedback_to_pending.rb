class ChangeKassiEventsWithoutFeedbackToPending < ActiveRecord::Migration
  def self.up
    KassiEvent.all.each do |kassi_event|
      if kassi_event.person_comments.size < 1
        kassi_event.update_attribute(:pending, 1)
      end  
    end  
  end

  def self.down
  end
end
