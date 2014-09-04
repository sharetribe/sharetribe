# == Schema Information
#
# Table name: custom_field_names
#
#  id              :integer          not null, primary key
#  value           :string(255)
#  locale          :string(255)
#  custom_field_id :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_custom_field_names_on_custom_field_id  (custom_field_id)
#  locale_index                                 (custom_field_id,locale)
#

require 'spec_helper'

describe CustomFieldName do
  describe "validations" do
    it "should have locale and value" do
      @name = CustomFieldName.new
      @name.should_not be_valid

      @name2 = CustomFieldName.new(:locale => "en")
      @name2.should_not be_valid

      @name2 = CustomFieldName.new(:locale => "en", :value => "Field name")
      @name2.should be_valid
    end
  end
end
