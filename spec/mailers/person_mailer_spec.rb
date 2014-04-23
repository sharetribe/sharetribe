require 'spec_helper'

def find_email_body_for(email)
  ActionMailer::Base.deliveries.select do |e|
    e.to.first == email.address
  end.first
end

# Give `arr` and `needle_arr` and get back
# true if all elements of `needle_arr` are included in `arr`
#
# http://stackoverflow.com/questions/7387937/ruby-rails-how-to-determine-if-one-array-contains-all-elements-of-another-array
def include_all?(arr, needle_arr)
  (needle_arr - arr).empty?
end

describe PersonMailer do

  # Include EmailSpec stuff (https://github.com/bmabey/email-spec)
  include(EmailSpec::Helpers)
  include(EmailSpec::Matchers)

  before(:each) do
    # @test_person, @session = get_test_person_and_session
    # @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
    @test_person = FactoryGirl.create(:person)
    @test_person2 = FactoryGirl.create(:person)
    @test_person2.locale = "en"
    @test_person2.save
    @community = FactoryGirl.create(:community)
  end

  it "should send email about a new message" do
    @conversation = FactoryGirl.create(:conversation)
    @conversation.participants = [@test_person2, @test_person]
    @message = FactoryGirl.create(:message)
    @message.conversation = @conversation
    @message.save
    email = PersonMailer.new_message_notification(@message, @community).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal @test_person2.confirmed_notification_email_addresses, email.to
    assert_equal "A new message in Sharetribe from #{@message.sender.name}", email.subject
  end

  it "should send email about a new comment to own listing" do
    @comment = FactoryGirl.create(:comment)
    @comment.author.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" })
    recipient = @comment.listing.author
    email = PersonMailer.new_comment_to_own_listing_notification(@comment, @community).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal recipient.confirmed_notification_email_addresses, email.to
    assert_equal "Teppo T has commented on your listing in Sharetribe", email.subject
  end

  it "should send email about listing with payment but without user's payment details" do
    community = FactoryGirl.create(:community)
    listing = FactoryGirl.create(:listing)
    recipient = listing.author
    email = PersonMailer.payment_settings_reminder(listing, recipient, community).deliver

    assert !ActionMailer::Base.deliveries.empty?
    assert_equal recipient.confirmed_notification_email_addresses, email.to
    assert_equal "Remember to add your payment details to receive payments", email.subject
  end

  describe "status changed" do

    before(:each) do
      @conversation = FactoryGirl.create(:conversation)
      @conversation.participants = [@conversation.listing.author, @test_person2]
      @test_person.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" })

      message = FactoryGirl.create(:message)
      @conversation.messages << message
      @conversation.messages.inspect
    end

    it "should send email about an accepted offer or request" do
      @conversation.transaction_transitions = [FactoryGirl.create(:transaction_transition, to_state: "accepted")]
      @conversation.save!
      @conversation.reload
      email = PersonMailer.conversation_status_changed(@conversation, @community).deliver
      assert !ActionMailer::Base.deliveries.empty?
      assert_equal @test_person2.confirmed_notification_email_addresses, email.to
      assert_equal "Your request was accepted", email.subject
    end

    it "should send email about a rejected offer or request" do
      @conversation.transaction_transitions = [FactoryGirl.create(:transaction_transition, to_state: "rejected")]
      @conversation.save!
      @conversation.reload
      email = PersonMailer.conversation_status_changed(@conversation, @community).deliver
      assert !ActionMailer::Base.deliveries.empty?
      assert_equal @test_person2.confirmed_notification_email_addresses, email.to
      assert_equal "Your request was rejected", email.subject
    end

  end

  it "should send email about approved Braintree account" do
    community = FactoryGirl.create(:community)
    person = FactoryGirl.create(:person)
    email = PersonMailer.braintree_account_approved(person, community).deliver

    assert !ActionMailer::Base.deliveries.empty?
    assert_equal person.confirmed_notification_email_addresses, email.to
    assert_equal "You are ready to receive payments", email.subject
    assert_equal "You are ready to receive payments", email.subject

    email.body.include?("Your payment information has been confirmed and you are now ready").should be_true
  end

  it "should send email about a new badge" do
    @badge = FactoryGirl.create(:badge)
    email = PersonMailer.new_badge(@badge, @community).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal @badge.person.confirmed_notification_email_addresses, email.to unless @badge.person.email.nil?
    assert_equal "You have achieved a badge 'Rookie' in Sharetribe!", email.subject
  end

  it "should send email about a new testimonial" do
    @test_person.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" })
    @conversation = FactoryGirl.create(:conversation)
    @conversation.participants << @test_person
    @conversation.participants << @test_person2
    @conversation.update_attribute(:status, "pending")
    @conversation.update_attribute(:status, "accepted")
    @participation = Participation.find_by_person_id_and_conversation_id(@test_person.id, @conversation.id)
    @testimonial = Testimonial.new(:grade => 0.75, :text => "Yeah", :author => @test_person, :receiver => @test_person2, :participation_id => @participation.id)
    email = PersonMailer.new_testimonial(@testimonial, @community).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal @test_person2.confirmed_notification_email_addresses, email.to
    assert_equal "Teppo T has given you feedback in Sharetribe", email.subject
  end

  it "should remind about testimonial" do
    @test_person.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" })
    @test_person.save
    Person.find(@test_person.id).update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" })
    @conversation = FactoryGirl.create(:conversation)
    @conversation.participants << @test_person
    @conversation.participants << @test_person2
    @conversation.update_attribute(:status, "pending")
    @conversation.update_attribute(:status, "accepted")
    @participation = Participation.find_by_person_id_and_conversation_id(@test_person2.id, @conversation.id)
    email = PersonMailer.testimonial_reminder(@conversation, @test_person2, @community).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal @test_person2.confirmed_notification_email_addresses, email.to
    assert_equal "Reminder: remember to give feedback to Teppo T", email.subject
  end

  it "should remind to accept or reject" do
    @test_person2.update_attributes({ "given_name" => "Jack", "family_name" => "Dexter" })
    @listing = FactoryGirl.create(:listing, :author => @test_person)
    @conversation = FactoryGirl.create(:conversation, :listing => @listing)
    @conversation.participants << @test_person
    @conversation.participants << @test_person2
    @conversation.update_attribute(:status, "pending")

    email = PersonMailer.accept_reminder(@conversation, "this_can_be_anything", @community).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal @test_person.confirmed_notification_email_addresses, email.to
    assert_equal "Remember to accept or reject a request from Jack D", email.subject
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
    m = CommunityMembership.create(:person_id => @test_person.id, :community_id => @community.id, :status => "accepted")
    m.update_attribute(:admin, true)
    email = PersonMailer.new_feedback(@feedback, @community).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [APP_CONFIG.feedback_mailer_recipients].concat(@test_person.confirmed_notification_email_addresses) , email.to
  end

  it "should send email to community admins of new member if wanted" do
    @community = FactoryGirl.create(:community, :email_admins_about_new_members => 1)
    m = CommunityMembership.create(:person_id => @test_person.id, :community_id => @community.id, :status => "accepted")
    m.update_attribute(:admin, true)
    email = PersonMailer.new_member_notification(@test_person2, @community.domain, @test_person2.email).deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal @test_person.confirmed_notification_email_addresses, email.to
    assert_equal "New member in #{@community.full_name('en')}", email.subject
  end

  describe "#welcome_email" do

    before(:each) do
      @c1 = FactoryGirl.create(:community)
      @p1 = FactoryGirl.create(:person, :emails => [ FactoryGirl.create(:email, :address => "update_tester@example.com") ])

      @p1.communities << @c1
    end

    it "should welcome a regular member" do
      @email = PersonMailer.welcome_email(@p1, @p1.communities.first)
      @email.should deliver_to("update_tester@example.com")
      @email.should have_subject("Welcome to #{@c1.full_name('en')} - here are some tips to get you started")
      @email.should have_body_text "Add something you could offer to others"
      @email.should_not have_body_text "You have now admin rights in this community."
    end

    it "should contain custom content if that is defined for the community" do
      @c1.community_customizations.create(:locale => "en", :welcome_email_content => "Custom email")
      @email = PersonMailer.welcome_email(@p1, @p1.communities.first)
      @email.should have_body_text "Custom email"
      @email.should_not have_body_text "Add something you could offer to others."
      @email.should_not have_body_text "You have now admin rights in this community."
    end

    it "should contain admin info if the receipient is an administrator" do
      @p1.update_attribute(:is_admin, true)
      @email = PersonMailer.welcome_email(@p1, @p1.communities.first)
      @email = PersonMailer.welcome_email(@p1, @p1.communities.first)
      @email.should deliver_to("update_tester@example.com")
      @email.should have_subject("You just created #{@c1.full_name('en')} - here are some tips to get you started")
      @email.should have_body_text "You have now admin rights in this community."
    end

  end

  describe "#community_updates" do

    before(:each) do
      @c1 = FactoryGirl.create(:community)
      @p1 = FactoryGirl.create(:person, :emails => [ FactoryGirl.create(:email, :address => "update_tester@example.com") ])
      @p1.communities << @c1
      @l1 = FactoryGirl.create(:listing,
          :transaction_type => FactoryGirl.create(:transaction_type_request),
          :title => "bike",
          :description => "A very nice bike",
          :created_at => 3.days.ago,
          :author => @p1).communities = [@c1]
      @l2 = FactoryGirl.create(:listing,
          :title => "hammer",
          :created_at => 2.days.ago,
          :description => "<b>shiny</b> new hammer, see details at http://en.wikipedia.org/wiki/MC_Hammer",
          :transaction_type => FactoryGirl.create(:transaction_type_sell))
      @l2.communities << @c1
      @l3 = FactoryGirl.create(:listing,
          :title => "sledgehammer",
          :created_at => 12.days.ago,
          :description => "super <b>shiny</b> sledgehammer, borrow it!",
          :transaction_type => FactoryGirl.create(:transaction_type_lend)).communities = [@c1]

      @email = PersonMailer.community_updates(@p1, @p1.communities.first)
    end

    it "should have correct address and subject" do
      @email.should deliver_to("update_tester@example.com")
      @email.should have_subject("Sharetribe #{@c1.name} community update")
    end

    it "should contain latest listings" do
      @email.should have_body_text("A very nice bike")
      @email.should have_body_text("Sell: ")
      @email.should have_body_text("new hammer")
    end

    it "should have correct links" do
      @email.should have_body_text(/.*<a href=\"http\:\/\/#{@c1.domain}\.#{APP_CONFIG.domain}\/#{@p1.locale}\/listings\/#{@l2.id}\?auth\=#{@p1.auth_tokens.last.token}\&amp;ref=weeklymail.*/)
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

      # for some reason there were more existing users here than should, which confused results
      # delete all to have clear table
      Person.all.each(&:destroy)

      @c1 = FactoryGirl.create(:community)
      @c2 = FactoryGirl.create(:community)
      @p1 = FactoryGirl.create(:person)
      @p1.communities << @c1
      @p2 = FactoryGirl.create(:person)
      @p2.communities << @c1
      @p2.communities << @c2

      @l1 = FactoryGirl.create(:listing,
          :transaction_type => FactoryGirl.create(:transaction_type_request),
          :title => "bike",
          :description => "A very nice bike",
          :created_at => 3.hours.ago,
          :author => @p1).communities = [@c1]
      @l2 = FactoryGirl.create(:listing,
          :transaction_type => FactoryGirl.create(:transaction_type_request),
          :title => "motorbike",
          :description => "fast!",
          :created_at => 1.hours.ago,
          :author => @p2).communities = [@c2]

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
      (include_all?(ActionMailer::Base.deliveries[0].to, @p2.confirmed_notification_email_addresses) || include_all?(ActionMailer::Base.deliveries[0].to, @p4.confirmed_notification_email_addresses)).should be_true
      (include_all?(ActionMailer::Base.deliveries[1].to, @p2.confirmed_notification_email_addresses) || include_all?(ActionMailer::Base.deliveries[1].to, @p4.confirmed_notification_email_addresses)).should be_true
      (include_all?(ActionMailer::Base.deliveries[2].to, @p2.confirmed_notification_email_addresses) || include_all?(ActionMailer::Base.deliveries[2].to, @p4.confirmed_notification_email_addresses)).should be_true
      ActionMailer::Base.deliveries.size.should == 3
    end

    it "should contain specific time information" do
      @p1.update_attribute(:community_updates_last_sent_at, 1.day.ago)
      PersonMailer.deliver_community_updates
      ActionMailer::Base.deliveries.size.should == 4
      email = find_email_body_for(@p1.emails.first)
      email.body.include?("during the past 1 day").should be_true
      email = find_email_body_for(@p2.emails.first)
      email.body.include?("during the past 14 day").should be_true
      email = find_email_body_for(@p4.emails.first)
      email.body.include?("during the past 9 day").should be_true
    end

    it "should send with default 7 days to those with nil as last time sent" do
      @p5 = FactoryGirl.create(:person)
      @p5.communities << @c1
      @p5.update_attribute(:community_updates_last_sent_at, nil)
      PersonMailer.deliver_community_updates
      ActionMailer::Base.deliveries.size.should == 4
      email = find_email_body_for(@p5.emails.first)
      email.should_not be_nil
      #ActionMailer::Base.deliveries[3].to.include?(@p5.email).should be_true
      email.body.include?("during the past 7 days").should be_true
    end

  end

  describe "#deliver_open_content_messages" do

    it "sends the mail to everyone on the list" do
      message = <<-MESSAGE
        New stuff in the service.

        Go check it out at http://example.com!
      MESSAGE

      people = [@test_person, @test_person2]
      PersonMailer.deliver_open_content_messages(people, "News", message)

      ActionMailer::Base.deliveries.size.should == 2

      include_all?(ActionMailer::Base.deliveries[0].to, @test_person.confirmed_notification_email_addresses).should be_true
      include_all?(ActionMailer::Base.deliveries[1].to, @test_person2.confirmed_notification_email_addresses).should be_true
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
      include_all?(ActionMailer::Base.deliveries[0].to, @test_person.confirmed_notification_email_addresses).should be_true
      include_all?(ActionMailer::Base.deliveries[1].to, @test_person2.confirmed_notification_email_addresses).should be_true
      include_all?(ActionMailer::Base.deliveries[2].to, @test_person3.confirmed_notification_email_addresses).should be_true
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

      include_all?(ActionMailer::Base.deliveries[0].to, @test_person.confirmed_notification_email_addresses).should be_true
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
        include_all?(ActionMailer::Base.deliveries[0].to, @test_person.confirmed_notification_email_addresses).should be_true
        include_all?(ActionMailer::Base.deliveries[1].to, @test_person2.confirmed_notification_email_addresses).should be_true
        include_all?(ActionMailer::Base.deliveries[2].to, @test_person3.confirmed_notification_email_addresses).should be_true
        ActionMailer::Base.deliveries[0].subject.should == "changes coming"
        ActionMailer::Base.deliveries[1].subject.should == "Ahorro ahora!"
        ActionMailer::Base.deliveries[2].subject.should == "Ahorro ahora!"
        ActionMailer::Base.deliveries[0].body.include?("Check it out").should be_true
        ActionMailer::Base.deliveries[1].body.include?("nuevas cosas").should be_true
        ActionMailer::Base.deliveries[2].body.include?("muy buenas").should be_true

    end

  end

end
