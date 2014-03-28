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
