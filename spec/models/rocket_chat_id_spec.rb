# == Schema Information
#
# Table name: rocket_chat_ids
#
#  id         :bigint           not null, primary key
#  RC_id      :string(255)
#  person_id  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe RocketChatId, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
