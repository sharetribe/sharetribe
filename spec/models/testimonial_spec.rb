# == Schema Information
#
# Table name: testimonials
#
#  id               :integer          not null, primary key
#  grade            :float(24)
#  text             :text(65535)
#  author_id        :string(255)
#  participation_id :integer
#  transaction_id   :integer
#  created_at       :datetime
#  updated_at       :datetime
#  receiver_id      :string(255)
#  blocked          :boolean          default(FALSE)
#
# Indexes
#
#  index_testimonials_on_author_id       (author_id)
#  index_testimonials_on_receiver_id     (receiver_id)
#  index_testimonials_on_transaction_id  (transaction_id)
#

require 'spec_helper'

describe Testimonial, type: :model do

  before(:each) do
    @testimonial = FactoryGirl.build(:testimonial)
  end

  it "is valid with valid attributes" do
    expect(@testimonial).to be_valid
  end

  it "is valid without text" do
    @testimonial.text = nil
    expect(@testimonial).to be_valid
  end

  it "is not valid without valid grade" do
    @testimonial.grade = nil
    expect(@testimonial).not_to be_valid
    @testimonial.grade = -1
    expect(@testimonial).not_to be_valid
    @testimonial.grade = 2
    expect(@testimonial).not_to be_valid
    @testimonial.grade = 1
    expect(@testimonial).to be_valid
  end

end
