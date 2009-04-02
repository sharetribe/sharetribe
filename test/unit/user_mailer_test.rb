require 'test_helper'

class UserMailerTest < ActionMailer::TestCase  
  
  def test_notification_of_new_message
    recipient = people(:two)
    message = messages(:valid_message)
    mail = UserMailer.create_notification_of_new_message(recipient, message)
    assert_equal(KASSI_MAIL_FROM_ADRESS, mail.from.first)
    assert_equal(message.sender.name + " on lähettänyt sinulle viestin Kassissa", mail.subject)
    assert_equal(recipient.email, mail.to.first)
  end
  
  def test_notification_of_new_comment
    comment = listing_comments(:third_comment)
    mail = UserMailer.create_notification_of_new_comment(comment)
    assert_equal(KASSI_MAIL_FROM_ADRESS, mail.from.first)
    assert_equal(comment.author.name + ' on kommentoinut ilmoitustasi "' + comment.listing.title + '"', mail.subject)
    assert_equal(comment.listing.author.email, mail.to.first)
  end
  
end

