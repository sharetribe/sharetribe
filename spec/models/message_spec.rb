# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  sender_id       :string(255)
#  content         :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#  conversation_id :integer
#
# Indexes
#
#  index_messages_on_conversation_id  (conversation_id)
#

require 'spec_helper'

describe Message, type: :model do

  before(:each) do
    @message = FactoryGirl.build(:message)
  end

  it "is valid with valid attributes" do
    expect(@message).to be_valid
  end

  it "is not valid with content" do
    @message.content = nil
    expect(@message).not_to be_valid
    @message.content = ""
    expect(@message).not_to be_valid
    @message.content = "test"
    expect(@message).to be_valid
  end

  it "is not valid without sender" do
    @message.sender = nil
    expect(@message).not_to be_valid
  end

end
