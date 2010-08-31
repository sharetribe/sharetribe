require 'spec_helper'

describe Comment do
  
  before(:all) do
    @test_person, @session = get_test_person_and_session
    @test_person2 = get_test_person_and_session("kassi_testperson2")[0]
    @test_person2.locale = "en"
    @test_person2.save
  end   

  it "should send email about new message" do
    @conversation = Factory(:conversation)
    @conversation.participants << @test_person
    @conversation.participants << @test_person2
    @message = Factory(:message)
    @message.conversation = @conversation
    @message.save
    email = PersonMailer.new_message_notification(@message).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [@test_person2.email], email.to
    assert_equal "You have a new message in Kassi", email.subject
  end
  
  it "should send email about new comment to own listing" do
    @comment = Factory(:comment)
    email = PersonMailer.new_comment_to_own_listing_notification(@comment).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [@test_person.email], email.to
    assert_equal "Teppo Testaaja has commented your listing in Kassi", email.subject
  end

end