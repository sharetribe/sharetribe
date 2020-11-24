class CreateStripeTablesAndFields < ActiveRecord::Migration[5.1]
  def change
    add_column :payment_settings, :api_client_id, :string unless column_exists?(:payment_settings, :api_client_id)
    add_column :payment_settings, :api_private_key, :string unless column_exists?(:payment_settings, :api_private_key)
    add_column :payment_settings, :api_publishable_key, :string unless column_exists?(:payment_settings, :api_publishable_key)
    add_column :payment_settings, :api_verified, :boolean unless column_exists?(:payment_settings, :api_verified)
    add_column :payment_settings, :api_visible_private_key, :string unless column_exists?(:payment_settings, :api_visible_private_key)
    add_column :payment_settings, :api_country, :string unless column_exists?(:payment_settings, :api_country)

    add_column :marketplace_setup_steps, :payment, :boolean, default: false unless column_exists?(:marketplace_setup_steps, :payment)
    MarketplaceSetupSteps.update_all('payment = paypal') rescue nil

    drop_table :stripe_accounts if table_exists? :stripe_accounts
    drop_table :stripe_payments if table_exists? :stripe_payments

    create_table :stripe_accounts do |t|
      t.string      :person_id
      t.integer     :community_id

      # Seller fields
      t.string      :stripe_seller_id # acct_12QkqYGSOD4VcegJ
      
      # minimal identity info
      t.string      :first_name
      t.string      :last_name
      t.string      :address_country
      t.string      :address_city
      t.string      :address_line1
      t.string      :address_postal_code
      t.string      :address_state
      t.date        :birth_date
      
      # TOS acceptance
      t.datetime    :tos_date
      t.string      :tos_ip
      
      # bank info
      t.string      :stripe_bank_id
      t.string      :bank_account_last_4

      # Buyer fields
      t.string      :stripe_customer_id
      t.string      :stripe_source_info    # visible CC data

      t.timestamps
    end

    create_table :stripe_payments do |t|
      t.integer   :community_id
      t.integer   :transaction_id
      t.string    :payer_id
      t.string    :receiver_id
      t.string    :status
      t.integer   :sum_cents
      t.integer   :commission_cents
      t.string    :currency
      t.string    :stripe_charge_id
      t.string    :stripe_transfer_id
      t.integer   :fee_cents
      t.integer   :real_fee_cents
      t.integer   :subtotal_cents
      t.datetime  :transfered_at
      t.datetime  :available_on
      t.timestamps
    end
    
  end
end
