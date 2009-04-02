require 'test_helper'

class UserMailerTest < ActionMailer::TestCase  
  
  def setup
    @test_person1, @session1 = get_test_person_and_session("kassi_testperson1")
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
    @cookie1 = @session1.cookie
    @cookie2 = @session2.cookie
  end
  
  def test_notification_of_new_message
    recipient = people(:two)
    message = messages(:valid_message)
    # Message is sent by person 1, so using cookie 1
    mail = UserMailer.create_notification_of_new_message(recipient, message, @cookie1)
    assert_equal(KASSI_MAIL_FROM_ADRESS, mail.from.first)
    assert_equal(message.sender.name + " on lähettänyt sinulle viestin Kassissa", mail.subject)
    assert_equal(recipient.email(@cookie2), mail.to.first)
  end
  
  def test_notification_of_new_comment
    comment = listing_comments(:third_comment)
    # Comment is left by person 2, so using cookie 2
    mail = UserMailer.create_notification_of_new_comment(comment, @cookie2)
    assert_equal(KASSI_MAIL_FROM_ADRESS, mail.from.first)
    assert_equal(comment.author.name + ' on kommentoinut ilmoitustasi "' + comment.listing.title + '"', mail.subject)
    assert_equal(comment.listing.author.email(@cookie1), mail.to.first)
  end
  
end

