require 'spec_helper'

describe PersonMailer do
  fixtures :people, :communities, :community_memberships
  
  before(:each) do
    @test_person, @session = get_test_person_and_session
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
    @test_person2.locale = "en"
    @test_person2.save
    @cookie = (@session.present? ? @session.cookie : nil)
    
  end   

  it "should send email about a new message" do
    @conversation = Factory(:conversation)
    @conversation.participants = [@test_person2, @test_person]
    @message = Factory(:message)
    @message.conversation = @conversation
    @message.save
    email = PersonMailer.new_message_notification(@message).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person2.email], email.to unless @test_person2.email.nil? #if running tests with Sharetribe account that doesn't get emails from ASI
    assert_equal "You have a new message in Sharetribe", email.subject
  end
  
  it "should send email about a new comment to own listing" do
    @comment = Factory(:comment)
    @comment.author.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" }, @cookie)
    recipient = @comment.listing.author
    email = PersonMailer.new_comment_to_own_listing_notification(@comment).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [recipient.email], email.to unless recipient.email.nil? #if running tests with Sharetribe account that doesn't get emails from ASI
    assert_equal "Teppo Testaaja has commented your listing in Sharetribe", email.subject
  end
  
  it "should send email about an accepted and rejected offer or request" do
    @conversation = Factory(:conversation)
     @conversation.participants = [@test_person2, @test_person]
    @test_person.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" }, @cookie)
    
    @conversation.update_attribute(:status, "accepted")
    email = PersonMailer.conversation_status_changed(@conversation).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person2.email], email.to unless @test_person2.email.nil? #if running tests with Sharetribe account that doesn't get emails from ASI
    assert_equal "Your offer was accepted", email.subject
    
    @conversation.update_attribute(:status, "rejected")
    email = PersonMailer.conversation_status_changed(@conversation).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person2.email], email.to unless @test_person2.email.nil? #if running tests with Sharetribe account that doesn't get emails from ASI
    assert_equal "Your offer was rejected", email.subject
  end
  
  it "should send email about a new badge" do
    @badge = Factory(:badge)
    email = PersonMailer.new_badge(@badge).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@badge.person.email], email.to unless @badge.person.email.nil? #if running tests with Sharetribe account that doesn't get emails from ASI
    assert_equal "You have achieved a badge 'Rookie' in Sharetribe!", email.subject
  end
  
  it "should send email about a new testimonial" do
    @test_person.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" }, @cookie)
    @conversation = Factory(:conversation)
    @conversation.participants << @test_person
    @conversation.participants << @test_person2 
    @conversation.update_attribute(:status, "accepted")
    @participation = Participation.find_by_person_id_and_conversation_id(@test_person.id, @conversation.id)
    @testimonial = Testimonial.new(:grade => 0.75, :text => "Yeah", :author => @test_person, :receiver => @test_person2, :participation_id => @participation.id)
    email = PersonMailer.new_testimonial(@testimonial).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person2.email], email.to unless @test_person2.email.nil? #if running tests with Sharetribe account that doesn't get emails from ASI
    assert_equal "Teppo Testaaja has given you feedback in Sharetribe", email.subject
  end
  
  it "should remind about testimonial" do
    @test_person.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" }, @cookie)
    @test_person.save
    Person.find(@test_person.id).update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" }, @cookie)
    @conversation = Factory(:conversation)
    @conversation.participants << @test_person
    @conversation.participants << @test_person2 
    @conversation.update_attribute(:status, "accepted")
    @participation = Participation.find_by_person_id_and_conversation_id(@test_person2.id, @conversation.id)
    email = PersonMailer.testimonial_reminder(@participation).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person2.email], email.to unless @test_person2.email.nil? #if running tests with Sharetribe account that doesn't get emails from ASI
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
    m = CommunityMembership.create(:person_id => @test_person.id, :community_id => @community.id)
    m.update_attribute(:admin, true)
    email = PersonMailer.new_feedback(@feedback, @community).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [APP_CONFIG.feedback_mailer_recipients, @test_person.email], email.to
  end
  
  it "should send email to admins of new contact request" do
    @contact_request = Factory(:contact_request)
    email = PersonMailer.contact_request_notification(@contact_request).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal APP_CONFIG.feedback_mailer_recipients.split(", "), email.to
  end
  
  it "should send email to community admins of new member if wanted" do
    @community = Factory(:community, :email_admins_about_new_members => 1)
    m = CommunityMembership.create(:person_id => @test_person.id, :community_id => @community.id)
    m.update_attribute(:admin, true)
    email = PersonMailer.new_member_notification(@test_person2, @community.domain, @test_person2.email).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person.email], email.to
    assert_equal "New member in #{@community.name} Kassi", email.subject
  end

  describe "#deliver_open_content_messages" do
    
    it "sends the mail to everyone on the list" do
      message = <<-MESSAGE
        New stuff in the service.
        
        Got check it out at http://example.com!
      MESSAGE
      
      people = [@test_person, @test_person2]
      PersonMailer.deliver_open_content_messages(people, "News", message)
      
      
      ActionMailer::Base.deliveries.size.should == 2
      
      ActionMailer::Base.deliveries[0].to.include?(@test_person.email).should be_true
      ActionMailer::Base.deliveries[1].to.include?(@test_person2.email).should be_true
      ActionMailer::Base.deliveries[0].subject.should == "News"
      ActionMailer::Base.deliveries[1].subject.should == "News"
      ActionMailer::Base.deliveries[0].body.include?("check it out").should be_true
      ActionMailer::Base.deliveries[1].body.include?("http://example.com").should be_true
    end
    
    it "uses right recipient locale if content is an array" do
      content = {
        "en"=>{
          "body"=>"We're doing new stuff\nCheck it out at...", 
          "subject"=>"changes coming"}, 
        "fi"=>{
          "body"=>"uutta tulossa\njepa.",
          "subject"=>"uudistuksia"},
      }
      
      @test_person2.update_attribute(:locale, "fi")
      @test_person3 = Factory(:person, :locale => "es")
      people = [@test_person, @test_person2, @test_person3]
      
      PersonMailer.deliver_open_content_messages(people, "SHOULD NOT BE SEEN", content, "en")
      
      ActionMailer::Base.deliveries.size.should == 3
      ActionMailer::Base.deliveries[0].to.include?(@test_person.email).should be_true
      ActionMailer::Base.deliveries[1].to.include?(@test_person2.email).should be_true
      ActionMailer::Base.deliveries[2].to.include?(@test_person3.email).should be_true
      ActionMailer::Base.deliveries[0].subject.should == "changes coming"
      ActionMailer::Base.deliveries[1].subject.should == "uudistuksia"
      ActionMailer::Base.deliveries[2].subject.should == "changes coming"      
      ActionMailer::Base.deliveries[0].body.include?("Check it out").should be_true
      ActionMailer::Base.deliveries[1].body.include?("uutta tulossa").should be_true
      ActionMailer::Base.deliveries[2].body.include?("new stuff").should be_true
      
      
    end
    
    it "skips inactive users" do
      message = "Just a short email"

      @test_person2.update_attribute(:active, false)
      people = [@test_person, @test_person2]
      PersonMailer.deliver_open_content_messages(people, "News", message)

      ActionMailer::Base.deliveries.size.should == 1

      ActionMailer::Base.deliveries[0].to.include?(@test_person.email).should be_true
      ActionMailer::Base.deliveries[0].subject.should == "News"
      ActionMailer::Base.deliveries[0].body.include?("Just a short email").should be_true
    end
    
    it "falls back to spanish from catalonian locale" do
       content = {
          "en"=>{
            "body"=>"We're doing new stuff\nCheck it out at...", 
            "subject"=>"changes coming"}, 
          "es"=>{
            "body"=>"nuevas cosas\nmuy buenas!",
            "subject"=>"Ahorro ahora!"},
        }

        @test_person2.update_attribute(:locale, "ru")
        @test_person2.update_attribute(:locale, "es")
        @test_person3 = Factory(:person, :locale => "ca")
        people = [@test_person, @test_person2, @test_person3]

        PersonMailer.deliver_open_content_messages(people, "SHOULD NOT BE SEEN", content, "en")

        ActionMailer::Base.deliveries.size.should == 3
        ActionMailer::Base.deliveries[0].to.include?(@test_person.email).should be_true
        ActionMailer::Base.deliveries[1].to.include?(@test_person2.email).should be_true
        ActionMailer::Base.deliveries[2].to.include?(@test_person3.email).should be_true
        ActionMailer::Base.deliveries[0].subject.should == "changes coming"
        ActionMailer::Base.deliveries[1].subject.should == "Ahorro ahora!"
        ActionMailer::Base.deliveries[2].subject.should == "Ahorro ahora!"      
        ActionMailer::Base.deliveries[0].body.include?("Check it out").should be_true
        ActionMailer::Base.deliveries[1].body.include?("nuevas cosas").should be_true
        ActionMailer::Base.deliveries[2].body.include?("muy buenas").should be_true
      
    end
    
  end
end