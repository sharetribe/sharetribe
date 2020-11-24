# == Schema Information
#
# Table name: participations
#
#  id               :integer          not null, primary key
#  person_id        :string(255)
#  conversation_id  :integer
#  is_read          :boolean          default(FALSE)
#  is_starter       :boolean          default(FALSE)
#  created_at       :datetime
#  updated_at       :datetime
#  last_sent_at     :datetime
#  last_received_at :datetime
#  feedback_skipped :boolean          default(FALSE)
#
# Indexes
#
#  index_participations_on_conversation_id  (conversation_id)
#  index_participations_on_person_id        (person_id)
#

require 'spec_helper'

describe Participation, type: :model do

  before(:each) do
    @participation = FactoryGirl.build(:participation)
  end

  it "is valid with valid attributes" do
    expect(@participation).to be_valid
  end

end
