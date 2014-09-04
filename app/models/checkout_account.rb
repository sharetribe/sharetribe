# == Schema Information
#
# Table name: checkout_accounts
#
#  id           :integer          not null, primary key
#  company_id   :string(255)
#  merchant_id  :string(255)      not null
#  merchant_key :string(255)      not null
#  person_id    :string(255)      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class CheckoutAccount < ActiveRecord::Base
  attr_accessible :merchant_id, :merchant_key, :company_id
  belongs_to :person
  #TODO Move to form object and remove after refactoring !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  attr_accessor :organization_address, :phone_number, :organization_website
end
