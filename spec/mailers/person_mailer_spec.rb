require 'spec_helper'

describe PersonMailer do
  fixtures :people, :communities, :community_memberships
  
  before(:all) do
    @test_person, @session = get_test_person_and_session
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
    @test_person2.locale = "en"
    @test_person2.save
  end   

  it "should send email about a new message" do
    @conversation = Factory(:conversation)
    @conversation.participants << @test_person
    @conversation.participants << @test_person2
    @message = Factory(:message)
    @message.conversation = @conversation
    @message.save
    email = PersonMailer.new_message_notification(@message).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person2.email], email.to unless @test_person2.email.nil? #if running tests with Kassi account that doesn't get emails from ASI
    assert_equal "You have a new message in Kassi", email.subject
  end
  
  it "should send email about a new comment to own listing" do
    @comment = Factory(:comment)
    @test_person.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" }, @session.cookie)
    email = PersonMailer.new_comment_to_own_listing_notification(@comment).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person.email], email.to unless @test_person2.email.nil? #if running tests with Kassi account that doesn't get emails from ASI
    assert_equal "Teppo Testaaja has commented your listing in Kassi", email.subject
  end
  
  it "should send email about an accepted and rejected offer or request" do
    @conversation = Factory(:conversation)
    @conversation.participants << @test_person
    @conversation.participants << @test_person2
    @test_person.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" }, @session.cookie)
    
    @conversation.update_attribute(:status, "accepted")
    email = PersonMailer.conversation_status_changed(@conversation).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person2.email], email.to unless @test_person2.email.nil? #if running tests with Kassi account that doesn't get emails from ASI
    assert_equal "Your offer was accepted", email.subject
    
    @conversation.update_attribute(:status, "rejected")
    email = PersonMailer.conversation_status_changed(@conversation).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person2.email], email.to unless @test_person2.email.nil? #if running tests with Kassi account that doesn't get emails from ASI
    assert_equal "Your offer was rejected", email.subject
  end
  
  it "should send email about a new badge" do
    @badge = Factory(:badge)
    email = PersonMailer.new_badge(@badge).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person.email], email.to unless @test_person2.email.nil? #if running tests with Kassi account that doesn't get emails from ASI
    assert_equal "You have achieved a badge 'Rookie' in Kassi!", email.subject
  end
  
  it "should send email about a new testimonial" do
    @conversation = Factory(:conversation)
    @conversation.participants << @test_person
    @conversation.participants << @test_person2
    @test_person.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" }, @session.cookie)
    @conversation.update_attribute(:status, "accepted")
    @participation = Participation.find_by_person_id_and_conversation_id(@test_person.id, @conversation.id)
    @testimonial = Testimonial.new(:grade => 0.75, :text => "Yeah", :author_id => @test_person.id, :receiver_id => @test_person2.id, :participation_id => @participation.id)
    email = PersonMailer.new_testimonial(@testimonial).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person2.email], email.to unless @test_person2.email.nil? #if running tests with Kassi account that doesn't get emails from ASI
    assert_equal "Teppo Testaaja has given you feedback in Kassi", email.subject
  end
  
  it "should remind about testimonial" do
    @conversation = Factory(:conversation)
    @conversation.participants << @test_person
    @conversation.participants << @test_person2
    @test_person.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" }, @session.cookie)
    @conversation.update_attribute(:status, "accepted")
    @participation = Participation.find_by_person_id_and_conversation_id(@test_person2.id, @conversation.id)
    email = PersonMailer.testimonial_reminder(@participation).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person2.email], email.to unless @test_person2.email.nil? #if running tests with Kassi account that doesn't get emails from ASI
    assert_equal "Reminder: remember to give feedback to Teppo Testaaja", email.subject
  end
  
  it "should send email to admins of new feedback" do
    @feedback = Factory(:feedback)
    @community = Factory(:community)
    email = PersonMailer.new_feedback(@feedback, @community).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal APP_CONFIG.feedback_mailer_recipients.split(", "), email.to
  end
  
  it "should send email to community admins of new feedback if that setting is on" do
    @feedback = Factory(:feedback)
    @community = Factory(:community, :feedback_to_admin => 1)
    CommunityMembership.create(:person_id => @test_person.id, :community_id => @community.id, :admin => 1)
    email = PersonMailer.new_feedback(@feedback, @community).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person.email], email.to
  end
  
  it "should send email to admins of new contact request" do
    @contact_request = Factory(:contact_request)
    email = PersonMailer.contact_request_notification(@contact_request).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal APP_CONFIG.feedback_mailer_recipients.split(", "), email.to
  end
  
  it "should send email to the contact request receiver" do
    @contact_request = Factory(:contact_request)
    email = PersonMailer.reply_to_contact_request(@contact_request.email, "en").deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@contact_request.email], email.to
    assert_equal "Thank you for your interest in Kassi!", email.subject
  end
  
  it "should send email to community admins of new member if wanted" do
    @community = Factory(:community, :email_admins_about_new_members => 1)
    email = PersonMailer.new_member_notification(@test_person2, @community.domain, @test_person2.email).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person.email], email.to
    assert_equal "New member in Test Kassi", email.subject
  end

end