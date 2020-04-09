class MoveDataFromKassiEventsPeopleToKassiEventParticipation < ActiveRecord::Migration[5.2]
def self.up

  end

  def self.down
    KassiEventParticipation.all.each do |kep|
      kep.destroy
    end  
  end
end
