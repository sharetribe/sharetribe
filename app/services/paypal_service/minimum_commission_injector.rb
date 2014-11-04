module PaypalService::MinimumCommissionInjector
  def minimum_commissions_cents
    @@loaded_min_commissions ||= YAML.load_file(min_commissions_path)
  end

  def min_commissions_path
    "#{Rails.root}/app/services/paypal_service/minimum_commissions.yml"
  end
end
