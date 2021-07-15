# == Schema Information
#
# Table name: api_keys
#
#  id           :bigint           not null, primary key
#  access_token :string(255)      not null
#  expires_at   :datetime         not null
#  user_id      :string(255)      not null
#  active       :boolean          default(TRUE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_api_keys_on_access_token  (access_token) UNIQUE
#  index_api_keys_on_user_id       (user_id)
#

require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
