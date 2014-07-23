module SettingsHelper

  # Class is selected if conversation type is currently selected
  def get_settings_tab_class(tab_name)
    current_tab_name = (action_name.eql?("show")) ? "profile" : action_name
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end

  def has_registered_payment_info?(community, person)
    community.payment_gateway.has_registered?(person)
  end

  def uses_mangopay?(community)
    community.payment_gateway.type == "Mangopay"
  end

  def uses_checkout?(community)
    community.payment_gateway.type == "Checkout"
  end

  def registered_checkout?(community, person)
    uses_checkout?(community) && has_registered_payment_info?(community, person)
  end

  def with_information_text(community, person, &block)
    if registered_checkout?(community, person)
      # Checkout

      block.call([
        t("organizations.form.merhcant_registration_done"),
        t("organizations.form.merhcant_registration_done_instructions").html_safe],
        :id => "payment-help-checkout-exists")
    else
      # Checkout
      block.call([t("organizations.form.merhcant_registration_detailed_instructions").html_safe], {})
    end
  end

  def with_bank_account_owner_name_field(community, &block)
    block.call if uses_mangopay?(community)
  end

  def with_bank_account_owner_address(community, &block)
    block.call if uses_mangopay?(community)
  end

  def with_organization_address(community, person, &block)
    block.call unless registered_checkout?(community, person)
  end

  def with_iban(community, &block)
    block.call if uses_mangopay?(community)
  end

  def with_bic(community, &block)
    block.call if uses_mangopay?(community)
  end

  def with_bic(community, &block)
    block.call if uses_mangopay?(community)
  end

  def with_company_id(community, person, &block)
    block.call unless registered_checkout?(community, person)
  end

  def with_organization_website(community, person, &block)
    block.call unless registered_checkout?(community, person)
  end

  def with_phone_number(community, person, &block)
    block.call unless registered_checkout?(community, person)
  end

  def with_submit_button(community, person, &block)
    block.call unless registered_checkout?(community, person)
  end

end
