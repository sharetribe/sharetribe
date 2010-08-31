require 'spec_helper'

describe Comment do
  
  before(:all) do
    @test_person, @session = get_test_person_and_session
  end   

  it "should send email about new message" do
    @test_person2 =  get_test_person_and_session("kassi_testperson2")[0]
    @test_person2.locale = "en"
    @test_person2.save
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

end