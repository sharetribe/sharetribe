module PaypalService::MinimumCommissions
  @@minimum_commissions

  module_function

  def get(currency)
    currency_code = currency.to_s.upcase
    get_all()[currency_code]
  end

  def get_all
    @@mnimum_commissions ||= Maybe(load_yaml).or_else({}).reduce({}) { |min_commissions, (k, v)|
      min_commissions[k] = Money.new(v, k)
      min_commissions
    }
  end

  def load_yaml
    if File.exists? path
      YAML.load_file(path)
    else
      {}
    end
  end

  def path
    "#{Rails.root}/app/services/paypal_service/minimum_commissions.yml"
  end
end
