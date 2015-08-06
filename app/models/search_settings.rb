# == Schema Information
#
# Table name: search_settings
#
#  id           :integer          not null, primary key
#  community_id :integer          not null
#  main_search  :string(255)      default("KEYWORD"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class SearchSettings < ActiveRecord::Base
  attr_accessible(
    :community_id,
    :main_search)

  validates_presence_of(
    :community_id,
    :main_search)

end
