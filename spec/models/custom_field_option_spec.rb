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

describe CustomFieldOption do
  describe "validations" do
    it "should have locale and value" do
      @name = CustomFieldOptionTitle.new
      @name.should_not be_valid

      @name2 = CustomFieldOptionTitle.new(:locale => "en")
      @name2.should_not be_valid

      @name2 = CustomFieldOptionTitle.new(:locale => "en", :value => "Field name")
      @name2.should be_valid
    end
  end
end
