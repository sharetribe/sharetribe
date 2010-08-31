include ApplicationHelper

class PersonMailer < ActionMailer::Base
  default :from => "Kassi <kassi@sizl.org>"
  layout 'email'

  def new_message_notification(message, request=nil)
    recipient = message.conversation.other_party(message.sender)
    @url = request ? "http://#{request.host}/#{recipient.locale}#{person_message_path(:person_id => recipient.id, :id => message.conversation.id.to_s)}" : "test_url"
    @settings_url = request ? "http://#{request.host}/#{recipient.locale}#{notifications_person_settings_path(:person_id => recipient.id)}" : "test_url"
    @message = message
    set_locale recipient.locale
    mail(:to => recipient.email,
         :subject => t("emails.new_message.you_have_a_new_message"))
  end

end