class AccountCreatedJob < Struct.new(:person_id, :community_id, :email)
  
  def perform
    community = Community.find(community_id)
    person = Person.find(person_id)
    EventFeedEvent.create(:person1_id => person.id, :community_id => community.id, :category => "join")
    PersonMailer.new_member_notification(person, community.domain, email).deliver if community.email_admins_about_new_members?
  end
  
end