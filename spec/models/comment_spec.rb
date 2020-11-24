# == Schema Information
#
# Table name: comments
#
#  id           :integer          not null, primary key
#  author_id    :string(255)
#  listing_id   :integer
#  content      :text(65535)
#  created_at   :datetime
#  updated_at   :datetime
#  community_id :integer
#
# Indexes
#
#  index_comments_on_listing_id  (listing_id)
#

require 'spec_helper'

describe Comment, type: :model do

  before(:each) do
    @comment = FactoryGirl.build(:comment)
  end

  it "is valid with valid attributes" do
    expect(@comment).to be_valid
  end

  it "is not valid without content" do
    @comment.content = nil
    expect(@comment).not_to be_valid
    @comment.content = ""
    expect(@comment).not_to be_valid
  end

  it "is not valid with too long content" do
    @comment.content = "a" * 5001
    expect(@comment).not_to be_valid
  end

end
