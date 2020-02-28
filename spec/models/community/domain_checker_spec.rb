# == Schema Information
#
# Table name: community_domain_checkers
#
#  id           :bigint           not null, primary key
#  community_id :bigint
#  domain       :string(255)
#  state        :string(255)      default(NULL)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_community_domain_checkers_on_community_id  (community_id)
#

require 'rails_helper'

RSpec.describe Community::DomainChecker, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
