include ApplicationHelper

class PersonMailer < ActionMailer::Base
  default :from => "Kassi <kassi@sizl.org>"
  layout 'email'

  def new_message_notification(message, host=nil)
    recipient = message.conversation.other_party(message.sender)
    @url = host ? "http://#{host}/#{recipient.locale}#{person_message_path(:person_id => recipient.id, :id => message.conversation.id.to_s)}" : "test_url"
    @settings_url = host ? "http://#{host}/#{recipient.locale}#{notifications_person_settings_path(:person_id => recipient.id)}" : "test_url"
    @message = message
    set_locale recipient.locale
    mail(:to => recipient.email,
         :subject => t("emails.new_message.you_have_a_new_message"))
  end
  
  def new_comment_to_own_listing_notification(comment, host=nil)
    recipient = comment.listing.author
    @url = host ? "http://#{host}/#{recipient.locale}#{listing_path(:id => comment.listing.id.to_s)}" : "test_url"
    @settings_url = host ? "http://#{host}/#{recipient.locale}#{notifications_person_settings_path(:person_id => recipient.id)}" : "test_url"
    @comment = comment
    set_locale recipient.locale
    mail(:to => recipient.email,
         :subject => t("emails.new_comment.you_have_a_new_comment", :author => comment.author.name))
  end

end