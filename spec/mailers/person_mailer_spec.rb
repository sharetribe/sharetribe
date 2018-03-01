require 'spec_helper'

describe PersonMailer, type: :mailer do

  # Include EmailSpec stuff (https://github.com/bmabey/email-spec)
  include(EmailSpec::Helpers)
  include(EmailSpec::Matchers)

  before(:each) do
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
    email = MailCarrier.deliver_now(PersonMailer.new_message_notification(@message, @community))
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal @test_person2.confirmed_notification_email_addresses, email.to
    assert_equal "A new message in Sharetribe from #{PersonViewUtils.person_display_name_for_type(@message.sender, 'first_name_with_initial')}", email.subject
  end

  it "should send email about a new comment to own listing" do
    @comment = FactoryGirl.create(:comment)
    @comment.author.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" })
    recipient = @comment.listing.author
    email = MailCarrier.deliver_now(PersonMailer.new_comment_to_own_listing_notification(@comment, @community))
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal recipient.confirmed_notification_email_addresses, email.to
    assert_equal "Teppo T has commented on your listing in Sharetribe", email.subject
  end

  it "should send email about listing with payment but without user's payment details" do
    community = FactoryGirl.create(:community)
    listing = FactoryGirl.create(:listing, listing_shape_id: 123)

    TransactionService::API::Api.settings.provision(
      community_id: community.id,
      payment_gateway: :paypal,
      payment_process: :preauthorize,
      active: true)

    recipient = listing.author
    email = MailCarrier.deliver_now(PersonMailer.payment_settings_reminder(listing, recipient, community))

    assert !ActionMailer::Base.deliveries.empty?
    assert_equal recipient.confirmed_notification_email_addresses, email.to
    assert_equal "Remember to add your payment details to receive payments", email.subject
  end

  describe "status changed" do

    let(:author) { FactoryGirl.build(:person) }
    let(:listing) { FactoryGirl.build(:listing, author: author, listing_shape_id: 123) }
    let(:starter) { FactoryGirl.build(:person, given_name: "Teppo", family_name: "Testaaja") }
    let(:conversation) { FactoryGirl.build(:conversation) }
    let(:transaction) { FactoryGirl.create(:transaction, listing: listing, starter: starter, conversation: conversation) }
    let(:community) { FactoryGirl.create(:community) }

    before(:each) do
      conversation.messages.build({
        sender: starter,
        content: "Test"
      })
    end

    it "should send email about an accepted offer or request" do
      transaction.transaction_transitions = [FactoryGirl.create(:transaction_transition, to_state: "accepted")]
      transaction.current_state = "accepted"
      transaction.save!
      transaction.reload
      email = MailCarrier.deliver_now(PersonMailer.conversation_status_changed(transaction, community))
      assert !ActionMailer::Base.deliveries.empty?
      assert_equal starter.confirmed_notification_email_addresses, email.to
      assert_equal "Your request was accepted", email.subject
    end

    it "should send email about a rejected offer or request" do
      transaction.transaction_transitions = [FactoryGirl.create(:transaction_transition, to_state: "rejected")]
      transaction.current_state = "rejected"
      transaction.save!
      transaction.reload
      email = MailCarrier.deliver_now(PersonMailer.conversation_status_changed(transaction, community))
      assert !ActionMailer::Base.deliveries.empty?
      assert_equal starter.confirmed_notification_email_addresses, email.to
      assert_equal "Your request was rejected", email.subject
    end

  end

  it "should send email about a new testimonial" do
    @test_person.update_attributes({ "given_name" => "Teppo", "family_name" => "Testaaja" })

    transition = FactoryGirl.build(:transaction_transition, to_state: "confirmed")
    listing = FactoryGirl.build(:listing,
                                transaction_process_id: 123, # not needed, but mandatory
                                listing_shape_id: 123, # not needed, but mandatory
                                author: @test_person)
    transaction = FactoryGirl.create(:transaction, starter: @test_person2, listing: listing, transaction_transitions: [transition])
    testimonial = FactoryGirl.create(:testimonial, grade: 0.75, text: "Yeah", author: @test_person, receiver: @test_person2, tx: transaction)

    email = MailCarrier.deliver_now(PersonMailer.new_testimonial(testimonial, @community))
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal @test_person2.confirmed_notification_email_addresses, email.to
    assert_equal "Teppo T has given you feedback in Sharetribe", email.subject
  end

  it "should remind about testimonial" do
    author = FactoryGirl.build(:person)
    starter = FactoryGirl.build(:person, given_name: "Teppo", family_name: "Testaaja")
    listing = FactoryGirl.build(:listing, author: author, listing_shape_id: 123)
    # Create is needed here, not exactly sure why
    conversation = FactoryGirl.create(:transaction, starter: starter, listing: listing)

    email = MailCarrier.deliver_now(PersonMailer.testimonial_reminder(conversation, author, @community))
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal author.confirmed_notification_email_addresses, email.to
    assert_equal "Reminder: remember to give feedback to Teppo T", email.subject
  end

  it "should send email to admins of new feedback" do
    @feedback = FactoryGirl.create(:feedback)
    @community = FactoryGirl.create(:community)
    email = MailCarrier.deliver_now(PersonMailer.new_feedback(@feedback, @community))
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal APP_CONFIG.feedback_mailer_recipients.split(", "), email.to
  end

  it "should send email to community admins of new feedback if that setting is on" do
    @feedback = FactoryGirl.create(:feedback)
    @community = FactoryGirl.create(:community)
    m = CommunityMembership.create(:person_id => @test_person.id, :community_id => @community.id, :status => "accepted")
    m.update_attribute(:admin, true)
    email = MailCarrier.deliver_now(PersonMailer.new_feedback(@feedback, @community))
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal @test_person.confirmed_notification_email_addresses, email.to
  end

  it "should send email to community admins of new member if wanted" do
    @community = FactoryGirl.create(:community, :email_admins_about_new_members => 1)
    m = CommunityMembership.create(:person_id => @test_person.id, :community_id => @community.id, :status => "accepted")
    m.update_attribute(:admin, true)
    email = MailCarrier.deliver_now(PersonMailer.new_member_notification(@test_person2, @community, @community.admins.first))
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal @test_person.confirmed_notification_email_addresses, email.to
    assert_equal "New member in #{@community.full_name('en')}", email.subject
  end

  describe "#welcome_email" do

    before(:each) do
      @c1 = FactoryGirl.create(:community)
      @p1 = FactoryGirl.create(:person, :emails => [ FactoryGirl.create(:email, :address => "update_tester@example.com") ])

      @p1.accepted_community = @c1
    end

    it "should welcome a regular member" do
      @email = PersonMailer.welcome_email(@p1, @p1.accepted_community)
      expect(@email).to deliver_to("update_tester@example.com")
      expect(@email).to have_subject("Welcome to Sharetribe")
      expect(@email).to have_body_text "Welcome to Sharetribe! Glad to have you on board."
      expect(@email).not_to have_body_text "You have now admin rights in this community."
    end

    it "should contain custom content if that is defined for the community" do
      @c1.community_customizations.first.update_attribute(:welcome_email_content, "Custom email")
      @email = PersonMailer.welcome_email(@p1, @p1.accepted_community)
      expect(@email).to have_body_text "Custom email"
      expect(@email).not_to have_body_text "Add something you could offer to others."
      expect(@email).not_to have_body_text "You have now admin rights in this community."
    end

  end

  describe "#new_listing_by_followed_person" do

    before do
      @community = FactoryGirl.create(:community)
      @listing = FactoryGirl.create(:listing, listing_shape_id: 123, community_id: @community.id)
      @recipient = FactoryGirl.create(:person)
    end

    it "should notify of a new listing" do
      email = MailCarrier.deliver_now(PersonMailer.new_listing_by_followed_person(@listing, @recipient, @community))
      assert !ActionMailer::Base.deliveries.empty?
      assert_equal @recipient.confirmed_notification_email_addresses, email.to
    end

  end

  describe "#community_member_email_from_admin" do
    let(:community) { FactoryGirl.create(:community) }
    let(:sender) { FactoryGirl.create(:person, member_of: community, member_is_admin: true) }
    let(:recipient) { FactoryGirl.create(:person, member_of: community) }

    it 'works ordinary user as recipient' do
      content = 'Have nice day!'
      email = PersonMailer.community_member_email_from_admin(sender, recipient, community, content, 'any')
      expect(email).to have_subject("A new message from the #{community.name('en')} team")
      expect(email).to have_body_text("Hello #{PersonViewUtils.person_display_name_for_type(recipient, 'first_name_only')},")
      expect(email).to have_body_text('Have nice day!')
    end

    it 'works yourself as recipient' do
      content = 'Have nice day!'
      email = PersonMailer.community_member_email_from_admin(sender, sender, community, content, 'any')
      expect(email).to have_subject("A new message from the #{community.name('en')} team")
      expect(email).to have_body_text("Hello #{PersonViewUtils.person_display_name_for_type(sender, 'first_name_only')},")
      expect(email).to have_body_text('Have nice day!')
    end
  end

  describe "#transaction_confirmed" do
    let(:community) { FactoryGirl.create(:community) }
    let(:seller) {
      FactoryGirl.create(:person, member_of: community,
                                  given_name: "Joan", family_name: "Smith")
    }
    let(:buyer) { FactoryGirl.create(:person, member_of: community) }
    let(:listing) { FactoryGirl.create(:listing, community_id: community.id, author: seller) }
    let(:confirmed_transaction) {
      FactoryGirl.create(:transaction, starter: buyer,
                                       community: community, listing: listing,
                                       current_state: 'confirmed')
    }

    it 'works with default payment gateway' do
      email = PersonMailer.transaction_confirmed(confirmed_transaction, community)
      expect(email.body).to have_text("Proto T has marked the order about 'Sledgehammer' completed. You can now give feedback to Proto.")
    end

    it 'works with stripe payment gateway' do
      confirmed_transaction.update_column(:payment_gateway, 'stripe')
      confirmed_transaction.reload
      email = PersonMailer.transaction_confirmed(confirmed_transaction, community)
      expect(email.body).to have_text("Proto T has marked the order about 'Sledgehammer' completed. The payment for this transaction has now been released to your bank account. You can now give feedback to Proto.")
    end
  end
end
