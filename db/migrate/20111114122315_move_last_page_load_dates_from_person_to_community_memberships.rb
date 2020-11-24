class MoveLastPageLoadDatesFromPersonToCommunityMemberships < ActiveRecord::Migration
  def self.up
    Person.all.each do |person|
      person.communities.each do |community|
        membership = CommunityMembership.find_by_person_id_and_community_id(person.id, community.id)
        membership.update_attribute(:last_page_load_date, person.last_page_load_date)
      end 
    end
  end

  def self.down
  end
end
