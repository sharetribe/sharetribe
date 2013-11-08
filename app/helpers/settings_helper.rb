module SettingsHelper
  
  # Class is selected if conversation type is currently selected
  def get_settings_tab_class(tab_name)
    current_tab_name = (action_name.eql?("show")) ? "profile" : action_name
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end

  def payment_gateway_to_use(community)
    # Currently, we always use the first (which is probably the only one)
    community.payment_gateways.first
  end

  def with_information_text(community, &block)
    if uses_mangopay(community)
      block.call(t(".these_settings_are_needed_in_order_to_receive_payments"))
    else
      # Checkout
      block.call(t("organizations.form.merhcant_registration_detailed_instructions").html_safe)
    end
  end

  def uses_mangopay(community)
    payment_gateway_to_use(community).type == "Mangopay"
  end

  def uses_checkout(community)
    payment_gateway_to_use(community).type == "Checkout"
  end

  def with_bank_account_owner_name_field(community, &block)
    block.call if uses_mangopay(community)
  end

  def with_bank_account_owner_address(community, &block)
    block.call if uses_mangopay(community)
  end

  def with_organization_address(community, &block)
    block.call if uses_checkout(community)
  end

  def with_iban(community, &block)
    block.call if uses_mangopay(community)
  end

  def with_bic(community, &block)
    block.call if uses_mangopay(community)
  end

  def with_bic(community, &block)
    block.call if uses_mangopay(community)
  end

  def with_company_id(community, &block)
    block.call if uses_checkout(community)
  end

  def with_organization_website(community, &block)
    block.call if uses_checkout(community)
  end

  def with_phone_number(community, &block)
    block.call if uses_checkout(community)
  end
  
end
