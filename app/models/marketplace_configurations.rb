# == Schema Information
#
# Table name: marketplace_configurations
#
#  id                    :integer          not null, primary key
#  community_id          :integer          not null
#  main_search           :string(255)      default("keyword"), not null
#  distance_unit         :string(255)      default("metric"), not null
#  limit_priority_links  :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  limit_search_distance :boolean          default(TRUE), not null
#  footer_style          :integer          default("dark")
#
# Indexes
#
#  index_marketplace_configurations_on_community_id  (community_id)
#

class MarketplaceConfigurations < ApplicationRecord
  DARK = 'dark'.freeze
  LIGHT = 'light'.freeze
  FOOTER_STYLES = {
    DARK => 0,
    LIGHT => 1
  }.freeze
  enum footer_style: FOOTER_STYLES
end
