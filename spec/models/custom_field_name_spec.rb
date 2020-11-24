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

describe CustomFieldName, type: :model do
  describe "validations" do
    it "should have locale and value" do
      @name = CustomFieldName.new
      expect(@name).not_to be_valid

      @name2 = CustomFieldName.new(:locale => "en")
      expect(@name2).not_to be_valid

      @name2 = CustomFieldName.new(:locale => "en", :value => "Field name")
      expect(@name2).to be_valid
    end
  end
end
