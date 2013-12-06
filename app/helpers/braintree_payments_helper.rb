module BraintreePaymentsHelper
  def with_braintree_field_name(name, opts={})
    name_attr = if APP_CONFIG.braintree_use_client_side_encryption
      { :data => { :'encrypted-name' => name }, :name => "" }
    else
      { :name => name }
    end

    opts.merge name_attr
  end
end