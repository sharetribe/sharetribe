
#
# Specify all country specific PayPal instruction texts / link in this module
#
# Feel free to add country-specific links to this module when ever you feel that there's
# a better page than the default page available
#

module PaypalCountryHelper

  FEE_URL = {
    # List all the contries that have the new fee page available
    "us" => "https://www.paypal.com/us/webapps/mpp/paypal-fees",
    "de" => "https://www.paypal.com/de/webapps/mpp/paypal-fees",
    "br" => "https://www.paypal.com/br/webapps/mpp/paypal-fees",
    "fr" => "https://www.paypal.com/fr/webapps/mpp/paypal-fees",
    "au" => "https://www.paypal.com/au/webapps/mpp/paypal-seller-fees",
    "no" => "https://www.paypal.com/no/webapps/mpp/paypal-fees",
    "nz" => "https://www.paypal.com/nz/webapps/mpp/paypal-fees",
    "jp" => "https://www.paypal.com/jp/webapps/mpp/paypal-fees",
  }

  FEE_URL.default = "https://www.paypal.com/cgi-bin/marketingweb?cmd=_display-xborder-fees-outside"

  POPUP_URL = {
    # List all the contries that have the popup URL available
    "us" => "https://www.paypal.com/us/webapps/mpp/paypal-popup",
    "de" => "https://www.paypal.com/de/webapps/mpp/paypal-popup",
    "fr" => "https://www.paypal.com/fr/webapps/mpp/paypal-popup",
    "au" => "https://www.paypal.com/au/webapps/mpp/paypal-popup",

    # List all the countries that should use the home URL, because popup is not available
    # (and default English popup is not good)
    "br" => "https://www.paypal.com/br/webapps/mpp/home",
    "no" => "https://www.paypal.com/no/webapps/mpp/home",
    "nz" => "https://www.paypal.com/nz/webapps/mpp/home",
    "jp" => "https://www.paypal.com/jp/webapps/mpp/home",
  }

  POPUP_URL.default = "https://www.paypal.com/webapps/mpp/paypal-popup"

  CREATE_ACCOUNT_URL = {
    "au" => "https://www.paypal.com/au/webapps/mpp/account-selection",
  }

  CREATE_ACCOUNT_URL.default = "https://www.paypal.com/%{country_code}/webapps/mpp/home"

  UPGRADE_ACCOUNT_URL = {
    "br" => "https://www.paypal.com/br/cgi-bin/webscr?cmd=_business-upgrade-flow",
    "jp" => "https://www.paypal.com/jp/webapps/mpp/merchant"
  }

  UPGRADE_ACCOUNT_URL.default = "https://www.paypal.com/%{country_code}/upgrade"

  RECEIVE_FUNDS_INFO_LABEL_TR_KEY = {
    "au" => "paypal_accounts.paypal_receive_funds_info_label_australia_only",
  }

  RECEIVE_FUNDS_INFO_LABEL_TR_KEY.default = "paypal_accounts.paypal_receive_funds_info_label"

  RECEIVE_FUNDS_INFO_TR_KEY = {
    "au" => "paypal_accounts.paypal_receive_funds_info_australia_only",
  }

  RECEIVE_FUNDS_INFO_TR_KEY.default = "paypal_accounts.paypal_receive_funds_info"

  module_function

  def fee_link(country_code)
    FEE_URL[country_code.to_s.downcase]
  end

  def popup_link(country_code)
    POPUP_URL[country_code.to_s.downcase]
  end

  def create_paypal_account_url(country_code)
    CREATE_ACCOUNT_URL[country_code.to_s.downcase] % {country_code: country_code}
  end

  def upgrade_paypal_account_url(country_code)
    UPGRADE_ACCOUNT_URL[country_code.to_s.downcase] % {country_code: country_code}
  end

  def receive_funds_info_label_tr_key(country_code)
    RECEIVE_FUNDS_INFO_LABEL_TR_KEY[country_code.to_s.downcase]
  end

  def receive_funds_info_tr_key(country_code)
    RECEIVE_FUNDS_INFO_TR_KEY[country_code.to_s.downcase]
  end
end
