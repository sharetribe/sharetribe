# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  sender_id       :string(255)
#  content         :text
#  created_at      :datetime
#  updated_at      :datetime
#  conversation_id :integer
#
# Indexes
#
#  index_messages_on_conversation_id  (conversation_id)
#

require 'spec_helper'

describe Message do

  before(:each) do
    @message = FactoryGirl.build(:message)
  end

  it "is valid with valid attributes" do
    @message.should be_valid
  end

  it "is not valid with content" do
    @message.content = nil
    @message.should_not be_valid
    @message.content = ""
    @message.should_not be_valid
    @message.content = "test"
    @message.should be_valid
  end

  it "is not valid without sender" do
    @message.sender = nil
    @message.should_not be_valid
  end

end
