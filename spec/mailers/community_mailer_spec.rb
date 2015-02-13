require 'spec_helper'

def find_email_body_for(email)
  ActionMailer::Base.deliveries.select do |e|
    e.to.first == email.address
  end.first
end

describe "CommunityMailer" do

  # Include EmailSpec stuff (https://github.com/bmabey/email-spec)
  include(EmailSpec::Helpers)
  include(EmailSpec::Matchers)

  describe "#community_updates" do

    before(:each) do
      @c1 = FactoryGirl.create(:community)
      @c1.community_customizations.first.update_attribute(:name, "MarketTestPlace")

      @p1 = FactoryGirl.create(:person, :emails => [ FactoryGirl.create(:email, :address => "update_tester@example.com") ])
      @p1.communities << @c1
      @l2 = FactoryGirl.create(:listing,
          :title => "hammer",
          :created_at => 2.days.ago,
          :updates_email_at => 2.days.ago,
          :description => "<b>shiny</b> new hammer, see details at http://en.wikipedia.org/wiki/MC_Hammer",
          :transaction_type => FactoryGirl.create(:transaction_type_sell))
      @l2.communities << @c1

      @email = CommunityMailer.community_updates(
        @p1,
        @p1.communities.first,
        [@l2]
      )
    end

    it "should have correct address and subject" do
      @email.should deliver_to("update_tester@example.com")
      @email.should have_subject("MarketTestPlace update")
    end

    it "should have correct links" do
      @email.should have_body_text(/.*<a href=\"http\:\/\/#{@c1.domain}\.#{APP_CONFIG.domain}\/#{@p1.locale}\/listings\/#{@l2.id}\?ref=weeklymail.*/)
    end

    it "should include valid auth_token in links" do
      token = @p1.auth_tokens.last.token
      @email.should have_body_text("?auth=#{token}")
    end

    it "should contain correct service name in the link" do
      @email.should have_body_text(/that happened on <a href.+\">MarketTestPlace/)
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
      CommunityMailer.deliver_community_updates
      (include_all?(ActionMailer::Base.deliveries[0].to, @p2.confirmed_notification_email_addresses) || include_all?(ActionMailer::Base.deliveries[0].to, @p4.confirmed_notification_email_addresses)).should be_truthy
      (include_all?(ActionMailer::Base.deliveries[1].to, @p2.confirmed_notification_email_addresses) || include_all?(ActionMailer::Base.deliveries[1].to, @p4.confirmed_notification_email_addresses)).should be_truthy
      (include_all?(ActionMailer::Base.deliveries[2].to, @p2.confirmed_notification_email_addresses) || include_all?(ActionMailer::Base.deliveries[2].to, @p4.confirmed_notification_email_addresses)).should be_truthy
      ActionMailer::Base.deliveries.size.should == 3
    end

    it "should contain specific time information" do
      @p1.update_attribute(:community_updates_last_sent_at, 1.day.ago)
      CommunityMailer.deliver_community_updates
      ActionMailer::Base.deliveries.size.should == 4
      email = find_email_body_for(@p1.emails.first)
      email.body.include?("during the past 1 day").should be_truthy
      email = find_email_body_for(@p2.emails.first)
      email.body.include?("during the past 14 day").should be_truthy
      email = find_email_body_for(@p4.emails.first)
      email.body.include?("during the past 9 day").should be_truthy
    end

    it "should send with default 7 days to those with nil as last time sent" do
      @p5 = FactoryGirl.create(:person)
      @p5.communities << @c1
      @p5.update_attribute(:community_updates_last_sent_at, nil)
      CommunityMailer.deliver_community_updates
      ActionMailer::Base.deliveries.size.should == 4
      email = find_email_body_for(@p5.emails.first)
      email.should_not be_nil
      #ActionMailer::Base.deliveries[3].to.include?(@p5.email).should be_truthy
      email.body.include?("during the past 7 days").should be_truthy
    end

  end
end
