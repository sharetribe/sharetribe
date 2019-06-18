# == Schema Information
#
# Table name: landing_page_versions
#
#  id           :integer          not null, primary key
#  community_id :integer          not null
#  version      :integer          not null
#  released     :datetime
#  content      :text(16777215)   not null
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_landing_page_versions_on_community_id_and_version  (community_id,version) UNIQUE
#

class LandingPageVersion < ApplicationRecord
  include LandingPageVersion::DataStructure

  belongs_to :community
end
