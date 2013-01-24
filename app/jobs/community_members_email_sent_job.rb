class CommunityMembersEmailSentJob < Struct.new(:sender_id, :community_id, :subject, :content, :locale) 
  
  def perform
    sender = Person.find(sender_id)
    current_community = Community.find(community_id)
    PersonMailer.community_member_emails(sender, current_community, subject, content, locale)
  end
  
end