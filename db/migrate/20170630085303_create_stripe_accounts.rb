class CreateStripeAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :stripe_accounts do |t|
      t.belongs_to  :person
      t.belongs_to  :community

      # Accounts: seller, buyer
      t.string      :account_type

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
      t.string      :ssn_last_4
      
      # TOS acceptance
      t.datetime    :tos_date
      t.string      :tos_ip
      
      # extra fields 
      t.boolean     :charges_enabled, default: false
      t.boolean     :transfers_enabled, default: false
      t.string      :personal_id_number
      
      # ID document file
      t.string      :verification_document # file_5dtoJkOhAxrMWb

      # bank info
      t.string      :stripe_bank_id
      t.string      :bank_account_number
      t.string      :bank_country
      t.string      :bank_currency
      t.string      :bank_account_holder_name
      t.string      :bank_account_holder_type
      t.string      :bank_routing_number

      # debit card info for payout - should be created from Stripe.js token
      t.string      :stripe_debit_card_id
      t.string      :stripe_debit_card_source

      # Buyer fields
      t.string      :stripe_customer_id
      t.string      :stripe_source_info  # visible CC data

      t.timestamps
    end
  end
end
