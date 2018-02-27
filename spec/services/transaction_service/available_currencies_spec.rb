require 'spec_helper'

describe TransactionService::AvailableCurrencies do
  context '#paypal_allows_country_and_currency?' do
    it 'works for all countries with valid currency' do
      country = ISO3166::Country.find_country_by_name('Finland')
      expect(paypal(country.alpha2, country.currency.iso_code)).to eq true
      country = ISO3166::Country.find_country_by_name('Brasil')
      expect(paypal(country.alpha2, country.currency.iso_code)).to eq true
      country = ISO3166::Country.find_country_by_name('Burkina Faso')
      expect(paypal(country.alpha2, country.currency.iso_code)).to eq false
      expect(paypal(country.alpha2, 'USD')).to eq true
    end

    def paypal(country, currency)
      TransactionService::AvailableCurrencies.paypal_allows_country_and_currency?(country, currency)
    end
  end

  context '#stripe_allows_country_and_currency?' do
    it 'works for listed countries' do
      country = ISO3166::Country.find_country_by_name('Finland')
      expect(stripe(country.alpha2, country.currency.iso_code)).to eq true
      country = ISO3166::Country.find_country_by_name('Brasil')
      expect(stripe(country.alpha2, country.currency.iso_code)).to eq false
      country = ISO3166::Country.find_country_by_name('Burkina Faso')
      expect(stripe(country.alpha2, country.currency.iso_code)).to eq nil
    end

    def stripe(country, currency)
      TransactionService::AvailableCurrencies.stripe_allows_country_and_currency?(country, currency, :destination)
    end
  end
end
