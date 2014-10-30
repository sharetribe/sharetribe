module PaypalService::MinimumCommissions
  @@minimum_commissions

  module_function

  def get(currency)
    get_all()[currency.to_s.upcase]
  end

  def get_all
    @@mnimum_commissions ||= Maybe(load_yaml).or_else({})
  end

  def load_yaml
    if File.exists? path
      YAML.load_file(path)
    end
  end

  def path
    "#{Rails.root}/app/services/paypal_service/minimum_commissions.yml"
  end
end
