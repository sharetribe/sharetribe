# == Schema Information
#
# Table name: custom_field_options
#
#  id              :integer          not null, primary key
#  custom_field_id :integer
#  sort_priority   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_custom_field_options_on_custom_field_id  (custom_field_id)
#

require 'spec_helper'

describe CustomFieldOption, type: :model do
  describe "validations" do
    it "should have locale and value" do
      @name = CustomFieldOptionTitle.new
      expect(@name).not_to be_valid

      @name2 = CustomFieldOptionTitle.new(:locale => "en")
      expect(@name2).not_to be_valid

      @name2 = CustomFieldOptionTitle.new(:locale => "en", :value => "Field name")
      expect(@name2).to be_valid
    end
  end
end
