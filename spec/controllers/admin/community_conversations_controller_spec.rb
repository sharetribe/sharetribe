require 'spec_helper'

describe Admin::CommunityConversationsController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
  let(:admin) { create_admin_for(community) }
  let(:person1) do
    FactoryGirl.create(:person, member_of: community,
                                username: 'nicolala',
                                given_name: 'Nicole',
                                family_name: 'Robinson',
                                emails: [FactoryGirl.build(:email, address: 'nicole@example.com')]
                      )
  end
  let(:person2) do
    FactoryGirl.create(:person, member_of: community,
                                username: 'tammyclark',
                                given_name: 'Tammy',
                                family_name: 'Clark',
                                emails: [FactoryGirl.build(:email, address: 'tammy.clark@example.com')]
                      )
  end
  let(:person3) do
    FactoryGirl.create(:person, member_of: community,
                                username: 'deniseh',
                                given_name: 'Denise',
                                family_name: 'Hill',
                                emails: [FactoryGirl.build(:email, address: 'Denise@foo.com')]
                      )
  end
  let(:conversation1) do
    conversation = FactoryGirl.create(:conversation, community: community,
                                                     starting_page: Conversation::PROFILE)
    conversation.participants << person1
    conversation.participants << person2
    conversation.messages << FactoryGirl.create(:message, sender: person1,
                                                          conversation: conversation,
                                                          content: 'educational')
    conversation.messages << FactoryGirl.create(:message, sender: person2,
                                                          conversation: conversation,
                                                          content: 'educative')
    conversation.messages << FactoryGirl.create(:message, sender: person1,
                                                          conversation: conversation,
                                                          content: 'enlighten')
    conversation
  end
  let(:conversation2) do
    conversation = FactoryGirl.create(:conversation, community: community,
                                                     starting_page: Conversation::PROFILE)
    conversation.participants << person1
    conversation.participants << person3
    conversation.messages << FactoryGirl.create(:message, sender: person1,
                                                          conversation: conversation,
                                                          content: 'devastate')
    conversation.messages << FactoryGirl.create(:message, sender: person3,
                                                          conversation: conversation,
                                                          content: 'overrun')
    conversation
  end


  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    sign_in_for_spec(admin)
  end

  describe "#index" do
    it 'works' do
      conversation1
      conversation2
      get :index, params: {community_id: community.id}
      service = assigns(:service)
      conversations = service.conversations
      expect(conversations.size).to eq 2
    end

    it 'search by keyword' do
      conversation1
      conversation2

      get :index, params: {community_id: community.id, q: 'nico'}
      service = assigns(:service)
      conversations = service.conversations
      expect(conversations.size).to eq 2

      get :index, params: {community_id: community.id, q: 'clark'}
      service = assigns(:service)
      conversations = service.conversations
      expect(conversations.size).to eq 1
      expect(conversations.first).to eq conversation1

      get :index, params: {community_id: community.id, q: 'tammy.clark@example.com'}
      service = assigns(:service)
      conversations = service.conversations
      expect(conversations.size).to eq 1
      expect(conversations.first).to eq conversation1

      get :index, params: {community_id: community.id, q: 'educative'}
      service = assigns(:service)
      conversations = service.conversations
      expect(conversations.size).to eq 1
      expect(conversations.first).to eq conversation1

      get :index, params: {community_id: community.id, q: 'ativ'}
      service = assigns(:service)
      conversations = service.conversations
      expect(conversations.size).to eq 1
      expect(conversations.first).to eq conversation1

      get :index, params: {community_id: community.id, q: 'denise'}
      service = assigns(:service)
      conversations = service.conversations
      expect(conversations.size).to eq 1
      expect(conversations.first).to eq conversation2
    end
  end

  describe "#show" do
    it 'works' do
      get :index, params: {community_id: community.id, id: conversation1.id}
      service = assigns(:service)
      conversation = service.conversation
      expect(conversation).to eq conversation1
      messages = service.conversation_messages
      expect(messages.size).to eq 3
    end
  end
end
