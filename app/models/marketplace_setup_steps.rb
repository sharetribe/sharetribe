# == Schema Information
#
# Table name: marketplace_setup_steps
#
#  id                     :integer          not null, primary key
#  community_id           :integer          not null
#  slogan_and_description :boolean          default(FALSE), not null
#  cover_photo            :boolean          default(FALSE), not null
#  filter                 :boolean          default(FALSE), not null
#  paypal                 :boolean          default(FALSE), not null
#  listing                :boolean          default(FALSE), not null
#  invitation             :boolean          default(FALSE), not null
#  stripe                 :boolean          default(FALSE)
#  payment                :boolean          default(FALSE)
#
# Indexes
#
#  index_marketplace_setup_steps_on_community_id  (community_id) UNIQUE
#

class MarketplaceSetupSteps < ApplicationRecord
  validates_presence_of(:community_id)

  def skip_payment
    update_attributes(payment: true)
  end
end
