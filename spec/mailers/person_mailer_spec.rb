require 'spec_helper'

describe PersonMailer do
  fixtures :people, :communities, :community_memberships
  
  # Include EmailSpec stuff (https://github.com/bmabey/email-spec)
  include(EmailSpec::Helpers)
  include(EmailSpec::Matchers)
  
  before(:each) do
    @test_person, @session = get_test_person_and_session
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
    @test_person2.locale = "en"
    @test_person2.save
    @cookie = (@session.present? ? @session.cookie : nil)
  end   

  it "should send email about a new message" do
    @conversation = FactoryGirl.create(:conversation)
    @conversation.participants = [@test_person2, @test_person]
    @message = FactoryGirl.create(:message)
    @message.conversation = @conversation
    @message.save
    email = PersonMailer.new_message_notification(@message).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person2.email], email.to unless @test_person2.email.nil? #if running tests with Sharetribe account that doesn't get emails from ASI
    assert_equal "You have a new message in Sharetribe", email.subject
  end
  
  it "should send email about a new comment to own listing" do
    @comment = FactoryGirl.create(:comment)
    @comment.author.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" }, @cookie)
    recipient = @comment.listing.author
    email = PersonMailer.new_comment_to_own_listing_notification(@comment).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [recipient.email], email.to unless recipient.email.nil? #if running tests with Sharetribe account that doesn't get emails from ASI
    assert_equal "Teppo Testaaja has commented on your listing in Sharetribe", email.subject
  end
  
  it "should send email about an accepted and rejected offer or request" do
    @conversation = FactoryGirl.create(:conversation)
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
    @badge = FactoryGirl.create(:badge)
    email = PersonMailer.new_badge(@badge).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@badge.person.email], email.to unless @badge.person.email.nil? #if running tests with Sharetribe account that doesn't get emails from ASI
    assert_equal "You have achieved a badge 'Rookie' in Sharetribe!", email.subject
  end
  
  it "should send email about a new testimonial" do
    @test_person.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" }, @cookie)
    @conversation = FactoryGirl.create(:conversation)
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
    @conversation = FactoryGirl.create(:conversation)
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
    @feedback = FactoryGirl.create(:feedback)
    @community = FactoryGirl.create(:community)
    email = PersonMailer.new_feedback(@feedback, @community).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal APP_CONFIG.feedback_mailer_recipients.split(", "), email.to
  end
  
  it "should send email to community admins of new feedback if that setting is on" do
    @feedback = FactoryGirl.create(:feedback)
    @community = FactoryGirl.create(:community, :feedback_to_admin => 1)
    m = CommunityMembership.create(:person_id => @test_person.id, :community_id => @community.id)
    m.update_attribute(:admin, true)
    email = PersonMailer.new_feedback(@feedback, @community).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [APP_CONFIG.feedback_mailer_recipients, @test_person.email], email.to
  end
  
  it "should send email to admins of new contact request" do
    @contact_request = FactoryGirl.create(:contact_request)
    email = PersonMailer.contact_request_notification(@contact_request).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal APP_CONFIG.feedback_mailer_recipients.split(", "), email.to
  end
  
  it "should send email to community admins of new member if wanted" do
    @community = FactoryGirl.create(:community, :email_admins_about_new_members => 1)
    m = CommunityMembership.create(:person_id => @test_person.id, :community_id => @community.id)
    m.update_attribute(:admin, true)
    email = PersonMailer.new_member_notification(@test_person2, @community.domain, @test_person2.email).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [@test_person.email], email.to
    assert_equal "New member in #{@community.name} Sharetribe", email.subject
  end
  
  describe "#community_updates" do
    
    before(:all) do
      @c1 = FactoryGirl.create(:community)
      @p1 = FactoryGirl.create(:person, :email => "update_tester@example.com")
      @p1.communities << @c1
      @l1 = FactoryGirl.create(:listing, 
          :listing_type => "request", 
          :title => "bike", 
          :description => "A very nice bike", 
          :created_at => 3.days.ago, 
          :author => @p1).communities = [@c1]
      @l2 = FactoryGirl.create(:listing, 
          :listing_type => "offer", 
          :title => "hammer", 
          :created_at => 2.days.ago, 
          :description => "<b>shiny</b> new hammer, see details at http://en.wikipedia.org/wiki/MC_Hammer", 
          :share_type => "sell").communities = [@c1]
      @l3 = FactoryGirl.create(:listing, 
          :listing_type => "offer", 
          :title => "sledgehammer", 
          :created_at => 12.days.ago, 
          :description => "super <b>shiny</b> sledgehammer, borrow it!", 
          :share_type => "lend").communities = [@c1]
          
      @email = PersonMailer.community_updates(@p1, @p1.communities.first)
    end

    it "should have correct address and subject" do
      @email.should deliver_to("update_tester@example.com")
      @email.should have_subject("#{@c1.name} Sharetribe community update")
    end
    
    it "should contain latest listings" do
      @email.should have_body_text("A very nice bike")
      @email.should have_body_text("new hammer")
    end
    
    it "should pick only new listings" do
      @email.should_not have_body_text("sledgehammer")
      
    end
    
    it "should include valid auth_token in links" do
      token = @p1.auth_tokens.last.token
      @email.should have_body_text("?auth=#{token}")
    end
    
    it "should not send, if no new listings" do
      @p1.update_attribute(:community_updates_last_sent_at, 1.day.ago)
      other_email = PersonMailer.community_updates(@p1, @p1.communities.first)
      other_email.class.should == ActionMailer::Base::NullMail
    end
    
  end
  
  describe "#deliver_community_updates" do
    before(:each) do
      @c1 = FactoryGirl.create(:community)
      @p1 = FactoryGirl.create(:person)
      @p1.communities << @c1
      @l1 = FactoryGirl.create(:listing, 
          :listing_type => "request", 
          :title => "bike", 
          :description => "A very nice bike", 
          :created_at => 3.hours.ago, 
          :author => @p1).communities = [@c1]
      @p2 = FactoryGirl.create(:person)
      @p2.communities << @c1
      @p3 = FactoryGirl.create(:person)
      @p3.communities << @c1
      @p4 = FactoryGirl.create(:person)
      @p4.communities << @c1

      
      @p1.update_attribute(:community_updates_last_sent_at, 8.hours.ago)
      @p2.update_attribute(:community_updates_last_sent_at, 14.days.ago)
      @p3.update_attribute(:community_updates_last_sent_at, 3.days.ago)
      @p4.update_attribute(:community_updates_last_sent_at, 9.days.ago)
      
      
      @p1.update_attribute(:min_days_between_community_updates, 1)
      @p2.update_attribute(:min_days_between_community_updates, 1)
      @p3.update_attribute(:min_days_between_community_updates, 7)
      @p4.update_attribute(:min_days_between_community_updates, 7)   
    end
    
    it "should send only to people who want it now" do
      PersonMailer.deliver_community_updates
      ActionMailer::Base.deliveries.size.should == 2
      ActionMailer::Base.deliveries[0].to.include?(@p2.email).should be_true
      ActionMailer::Base.deliveries[1].to.include?(@p4.email).should be_true
           
    end
    
    it "should contain specific time information" do
      @p1.update_attribute(:community_updates_last_sent_at, 1.day.ago)
      PersonMailer.deliver_community_updates
      ActionMailer::Base.deliveries.size.should == 3
      ActionMailer::Base.deliveries[0].body.include?("during the past 1 day").should be_true
      ActionMailer::Base.deliveries[1].body.include?("during the past 14 days").should be_true
      ActionMailer::Base.deliveries[2].body.include?("during the past 9 days").should be_true
    end
    
    it "should send with default 7 days to those with nil as last time sent" do
      @p5 = FactoryGirl.create(:person)
      @p5.communities << @c1
      @p5.update_attribute(:community_updates_last_sent_at, nil)     
      PersonMailer.deliver_community_updates
      ActionMailer::Base.deliveries.size.should == 3
      ActionMailer::Base.deliveries[2].to.include?(@p5.email).should be_true
      ActionMailer::Base.deliveries[2].body.include?("during the past 7 days").should be_true
    end
    
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
      @test_person3 = FactoryGirl.create(:person, :locale => "es")
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
        @test_person3 = FactoryGirl.create(:person, :locale => "ca")
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