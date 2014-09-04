# == Schema Information
#
# Table name: comments
#
#  id           :integer          not null, primary key
#  author_id    :string(255)
#  listing_id   :integer
#  content      :text
#  created_at   :datetime
#  updated_at   :datetime
#  community_id :integer
#
# Indexes
#
#  index_comments_on_listing_id  (listing_id)
#

require 'spec_helper'

describe Comment do

  before(:each) do
    @comment = FactoryGirl.build(:comment)
  end

  it "is valid with valid attributes" do
    @comment.should be_valid
  end

  it "is not valid without content" do
    @comment.content = nil
    @comment.should_not be_valid
    @comment.content = ""
    @comment.should_not be_valid
  end

  it "is not valid with too long content" do
    @comment.content = "a" * 5001
    @comment.should_not be_valid
  end

end
