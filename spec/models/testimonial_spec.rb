# == Schema Information
#
# Table name: testimonials
#
#  id               :integer          not null, primary key
#  grade            :float
#  text             :text
#  author_id        :string(255)
#  participation_id :integer
#  transaction_id   :integer
#  created_at       :datetime
#  updated_at       :datetime
#  receiver_id      :string(255)
#
# Indexes
#
#  index_testimonials_on_author_id       (author_id)
#  index_testimonials_on_receiver_id     (receiver_id)
#  index_testimonials_on_transaction_id  (transaction_id)
#

require 'spec_helper'

describe Testimonial do

  before(:each) do
    @testimonial = FactoryGirl.build(:testimonial)
  end

  it "is valid with valid attributes" do
    @testimonial.should be_valid
  end

  it "is valid without text" do
    @testimonial.text = nil
    @testimonial.should be_valid
  end

  it "is not valid without valid grade" do
    @testimonial.grade = nil
    @testimonial.should_not be_valid
    @testimonial.grade = -1
    @testimonial.should_not be_valid
    @testimonial.grade = 2
    @testimonial.should_not be_valid
    @testimonial.grade = 1
    @testimonial.should be_valid
  end

end
