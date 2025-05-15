require 'spec_helper'
require 'tempfile'

describe "Amazon Bounces", type: :request do

  before(:each) do
    @community = FactoryBot.create(:community, :domain => "market.custom.org")
  end

  describe "subscription confirmations" do
    context "sns_notification_token is unset" do
      before(:all) do
        @sns_notification_token = APP_CONFIG.sns_notification_token
        APP_CONFIG.sns_notification_token = nil
      end

      after(:all) do
        APP_CONFIG.sns_notification_token = @sns_notification_token
      end

      it 'does not open subscription notification url' do
        incoming_data = JSON.parse('{
            "SubscribeURL":"https://subscribe.example.com/confirm"
          }')

        stub_request(:get, "https://subscribe.example.com/confirm").to_return(status: 200, body: "", headers: {})

        post "https://market.custom.org/bounces?sns_notification_token=#{APP_CONFIG.sns_notification_token}", params: incoming_data.to_json.to_s, headers: { 'x-amz-sns-message-type' => 'subscriptionconfirmation'}

        expect(response.status).to eq(200)

        assert_not_requested :get, "https://subscribe.example.com/confirm"
      end
    end

    context "sns_notification_token is set" do
      it 'opens valid subscription notification url' do
        incoming_data = JSON.parse('{
            "SubscribeURL":"https://subscribe.example.com/confirm"
          }')

        stub_request(:get, "https://subscribe.example.com/confirm").to_return(status: 200, body: "", headers: {})

        post "https://market.custom.org/bounces?sns_notification_token=#{APP_CONFIG.sns_notification_token}", params: incoming_data.to_json.to_s, headers: { 'x-amz-sns-message-type' => 'subscriptionconfirmation'}
        expect(response.status).to eq(200)
        assert_requested :get, "https://subscribe.example.com/confirm"
      end

      it 'does not open non-http schemes' do
        incoming_data = JSON.parse('{
            "SubscribeURL":"file://foo"
          }')

        post "https://market.custom.org/bounces?sns_notification_token=#{APP_CONFIG.sns_notification_token}", params: incoming_data.to_json.to_s, headers: { 'x-amz-sns-message-type' => 'subscriptionconfirmation'}
        expect(response.status).to eq(400)
      end

      context "code_execution" do
        before(:all) do
          @tmp_file = Tempfile.new("ses_test")
        end

        after(:all) do
          @tmp_file.close!
        end

        it 'does not allow code execution' do
          incoming_data = JSON.parse("{
              \"SubscribeURL\":\"| echo foo >  #{@tmp_file.path}\"
            }")

          post "https://market.custom.org/bounces?sns_notification_token=#{APP_CONFIG.sns_notification_token}", params: incoming_data.to_json.to_s, headers: { 'x-amz-sns-message-type' => 'subscriptionconfirmation'}
          expect(response.status).to eq(400)
          # Need to allow some time for the execution to happen, it seems
          sleep 2
          expect(@tmp_file.size()).to eq(0)
        end
      end
    end
  end

  describe "test notifications" do
    it "when notificationType is bounce" do
      # Prepare
      @person = FactoryBot.create(:person, id: "123abc", min_days_between_community_updates: 4)
      @person.emails = [
        FactoryBot.create(:email, :address => "one@examplecompany.co", :send_notifications => true),
      ]

      incoming_data = JSON.parse('{
        "notificationType":"Bounce",
        "bounce":{
           "bounceType":"Permanent",
           "bounceSubType": "General",
           "bouncedRecipients":[
              {
                 "emailAddress":"one@examplecompany.co"
              }
           ],
           "timestamp":"2012-05-25T14:59:38.237-07:00",
           "feedbackId":"00000137860315fd-869464a4-8680-4114-98d3-716fe35851f9-000000"
        },
        "mail":{
           "timestamp":"2012-05-25T14:59:38.237-07:00",
           "messageId":"00000137860315fd-34208509-5b74-41f3-95c5-22c1edc3c924-000000",
           "source":"email_1337983178237@amazon.com",
           "destination":[
              "recipient1@example.com",
              "recipient2@example.com",
              "recipient3@example.com",
              "recipient4@example.com"
           ]
        }
      }')

      expect(@person.min_days_between_community_updates).to be_equal 4
      post "https://market.custom.org/bounces?sns_notification_token=#{APP_CONFIG.sns_notification_token}", params: incoming_data.to_json.to_s, headers: { 'x-amz-sns-message-type' => 'notification'}
      expect(Person.find_by_id(@person.id).min_days_between_community_updates).to be_equal 100000
    end

    it "when notificationType is Complaint" do
      # Prepare
      @person = FactoryBot.create(:person, id: "123abc", min_days_between_community_updates: 4)
      @person.emails = [
        FactoryBot.create(:email, :address => "one@examplecompany.co", :send_notifications => true),
      ]

      incoming_data = JSON.parse('{
        "notificationType":"Complaint",
        "complaint":{
           "userAgent":"Comcast Feedback Loop (V0.01)",
           "complainedRecipients":[
              {
                 "emailAddress":"one@examplecompany.co"
              }
           ],
           "complaintFeedbackType":"abuse",
           "arrivalDate":"2009-12-03T04:24:21.000-05:00",
           "timestamp":"2012-05-25T14:59:38.623-07:00",
           "feedbackId":"000001378603177f-18c07c78-fa81-4a58-9dd1-fedc3cb8f49a-000000"
        },
        "mail":{
           "timestamp":"2012-05-25T14:59:38.623-07:00",
           "messageId":"000001378603177f-7a5433e7-8edb-42ae-af10-f0181f34d6ee-000000",
           "source":"email_1337983178623@amazon.com",
           "destination":[
              "recipient1@example.com",
              "recipient2@example.com",
              "recipient3@example.com",
              "recipient4@example.com"
           ]
        }
      }')

      expect(@person.min_days_between_community_updates).to be_equal 4
      post "https://market.custom.org/bounces?sns_notification_token=#{APP_CONFIG.sns_notification_token}", params: incoming_data.to_json.to_s, headers: { 'x-amz-sns-message-type' => 'notification'}
      expect(Person.find_by_id(@person.id).min_days_between_community_updates).to be_equal 100000
    end

  end
end
