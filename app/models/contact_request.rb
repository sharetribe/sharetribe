# == Schema Information
#
# Table name: contact_requests
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  country          :string(255)
#  plan_type        :string(255)
#  marketplace_type :string(255)
#

class ContactRequest < ActiveRecord::Base
  # New are no more created, but this is saved as there's important data in DB
end
