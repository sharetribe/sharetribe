class CountryManager < ActiveRecord::Base
  attr_accessible :country, :email, :email_signature, :locale, :name
end
