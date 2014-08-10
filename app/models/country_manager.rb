# == Schema Information
#
# Table name: country_managers
#
#  id            :integer          not null, primary key
#  given_name    :string(255)
#  family_name   :string(255)
#  email         :string(255)
#  country       :string(255)
#  locale        :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  subject_line  :string(255)
#  email_content :text
#

class CountryManager < ActiveRecord::Base
  attr_accessible :country, :email, :email_signature, :locale, :name

  # Return all country codes where we have country managers
  def self.countries
    countries = []
    CountryManager.all.each do |cm|
      countries << cm.country unless cm.country.eql?("global")
    end
    countries
  end

end
