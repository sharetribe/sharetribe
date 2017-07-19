class StripeService::API::StripeApiWrapper
  class << self

    @@mutex = Mutex.new

    def payment_settings_for(community)
      PaymentSettings.where(community_id: community, payment_gateway: :stripe, payment_process: :preauthorize).first
    end

    def configure_payment_for(settings)
      Stripe.api_key = TransactionService::Store::PaymentSettings.decrypt_value(settings.api_private_key)
    end

    def reset_configurations
      Stripe.api_key = ""
    end

    # This method should be used for all actions that require setting correct
    # Merchant details for the Stripe gem
    def with_stripe_payment_config(community, &block)
      @@mutex.synchronize {
        payment_settings = payment_settings_for(community)
        configure_payment_for(payment_settings)

        return_value = block.call(payment_settings)

        reset_configurations

        return return_value
      }
    end

    def register_customer(community, email, card_token)
      with_stripe_payment_config(community) do |payment_settings|
        Stripe::Customer.create(
          email: email,
          card: card_token
        )
      end
    end

    def update_customer(community, customer_id, token)
      with_stripe_payment_config(community) do |payment_settings|
        customer = Stripe::Customer.retrieve(customer_id)
        customer.source = token
        customer.save
        customer
      end
    end

    def publishable_key(community)
      with_stripe_payment_config(community) do |payment_settings|
        payment_settings.api_publishable_key
      end
    end

    def charge(community, token, seller_account_id, amount, fee, currency, description)
      with_stripe_payment_config(community) do |payment_settings|
        case destination(community)
        when :seller
          Stripe::Charge.create({
            source: token,
            amount: amount,
            description: description,
            currency: currency,
            application_fee: fee,
            capture: false
          }, { stripe_account: seller_account_id })
        when :platform
          Stripe::Charge.create({
            customer: token,
            amount: amount,
            description: description,
            currency: currency,
            capture: false
          })
        end
      end
    end

    def capture_charge(community, charge_id, seller_id)
      with_stripe_payment_config(community) do |payment_settings|
        case destination(community)
        when :seller
          charge = Stripe::Charge.retrieve(charge_id, {stripe_account: seller_id})
        when :platform
          charge = Stripe::Charge.retrieve(charge_id)
        end
        charge.capture
      end
    end

    def create_token(community, customer_id, account_id)
      with_stripe_payment_config(community) do |payment_settings|
        Stripe::Token.create({customer: customer_id}, {stripe_account: account_id})
      end
    end

    def register_seller(community, account_info)
      with_stripe_payment_config(community) do |payment_settings|
        case destination(community)
        when :platform
          # platform holds captured funds until completion, up to 90 days, then makes transfer
          payout_mode = {}
        when :seller
          # managed accounts, make payout after completion om funds availability date
          payout_mode = {
            payout_schedule: {
              interval: 'manual'
            }
          }
        end
        Stripe::Account.create({
          managed: true,
          country: account_info[:address_country],
          legal_entity: {
            type: 'individual',
            first_name: account_info[:first_name],
            last_name: account_info[:last_name],
            address: {
              city: account_info[:address_city],
              state: account_info[:address_state],
              country: account_info[:address_country],
              postal_code: account_info[:address_postal_code],
              line1: account_info[:address_line1],
            },
            dob: {
              day: account_info[:birth_date].day,
              month: account_info[:birth_date].month,
              year: account_info[:birth_date].year,
            },
            ssn_last_4: (account_info[:address_country] == 'US' ? account_info[:ssn_last_4] : nil),
          },

          tos_acceptance: {
            date: account_info[:tos_date].to_i,
            ip: account_info[:tos_ip],
          }
        }.merge(payout_mode))
      end
    end

    def check_balance(community)
      with_stripe_payment_config(community) do |payment_settings|
        Stripe::Balance.retrieve
      end
    rescue => e
      nil
    end

    def create_bank_account(community, account_info)
      with_stripe_payment_config(community) do |payment_settings|
        stripe_account = Stripe::Account.retrieve account_info[:stripe_seller_id]
        stripe_account.external_accounts.create({
          external_account: {
            object: 'bank_account',
            account_number: account_info[:bank_account_number],
            currency:       account_info[:bank_currency],
            routing_number: account_info[:bank_routing_number],
            country:        account_info[:bank_country],
            account_holder_name: account_info[:bank_holder_name],
            account_holder_type: 'individual'
          }
        })
      end
    end

    def get_account_balance(community, account_id)
      with_stripe_payment_config(community) do |payment_settings|
        Stripe::Balance.retrieve({stripe_account: account_id})
      end
    end

    def perform_payout(community, account_id, amount_cents, currency)
      with_stripe_payment_config(community) do |payment_settings|
        Stripe::Payout.create({amount: amount_cents, currency: currency}, {stripe_account: account_id})
      end
    end

    def perform_transfer(community, account_id, amount_cents, amount_currency, initial_amount, charge_id)
      with_stripe_payment_config(community) do |payment_settings|
        charge = Stripe::Charge.retrieve(charge_id)
        balance_txn = Stripe::BalanceTransaction.retrieve(charge.balance_transaction)
        balance_currency = balance_txn.currency.upcase
        # when platform balance is, say in EUR, but prices are in USD, recalc amount
        fixed_amount = balance_currency == amount_currency ? amount_cents : (amount_cents * 1.0 / initial_amount * balance_txn.amount).to_i
        Stripe::Transfer.create({amount: fixed_amount, currency: balance_currency, destination: account_id, source_transaction: charge_id})
      end
    end

    def get_card_info(customer)
      default_id = customer.default_source
      customer.sources.data.each do |source|
        if source.id == default_id && source.object == 'card'
          masked_card =  [source.brand, "****#{source.last4}", "Exp.#{source.exp_month}/#{source.exp_year}"].join(" ")
          return [masked_card, source.country]
        end
      end
      return nil
    end

    def platform_country(community)
      with_stripe_payment_config(community) do |payment_settings|
        payment_settings[:api_country] || Stripe::Account.retrieve.country
      end
    end

    DESTINATION_TYPES = [:platform, :seller]
    # :platform - marketplace API account is responsible for fees, refunds, etc. funds are captured to platform account and then moved to seller by Transfer
    # :seller   - Custom Account for seller is responsible for fees, funds are sent by Payout
    def destination(community)
      APP_CONFIG.stripe_charge_destination.to_sym
    end

    STRIPE_FEE_MODES = [:put_on_buyer, :put_on_seller]
    # :put_on_buyer  - add estimated fee to total price, so instead of $100.00 user pays $103.30 and seller receives plain $100 minus marketplace commission
    # :put_on_seller - fee is charged from charge reciepint (seller or platform), so user pays $100.00 and seller receives $96.80 minus marketplace commission
    def fee_mode(community)
      APP_CONFIG.stripe_fee_mode.to_sym
    end

    def send_verification(community, account_id, personal_id_number, file_path)
      with_stripe_payment_config(community) do |payment_settings|
        document = Stripe::FileUpload.create({
            purpose: 'identity_document',
            file: File.new(file_path)
          },
          { stripe_account: account_id})
        account = Stripe::Account.retrieve(account_id)
        account.legal_entity.verification.document = document.id
        account.legal_entity.personal_id_number = personal_id_number
        account.save
      end
    end

    def get_seller_account(community, account_id)
      with_stripe_payment_config(community) do |payment_settings|
        Stripe::Account.retrieve(account_id)
      end
    end

    def get_customer_account(community, customer_id)
      with_stripe_payment_config(community) do |payment_settings|
        Stripe::Customer.retrieve(customer_id)
      end
    end

    def cancel_charge(community, charge_id, account_id, reason)
      with_stripe_payment_config(community) do |payment_settings|
        reason_data =  reason.present? ? {reason: reason} : {}
        case destination(community)
        when :platform
          Stripe::Refund.create({charge: charge_id}.merge(reason_data))
        when :seller
          Stripe::Refund.create({charge: charge_id}.merge(reason_data), {stripe_account: account_id})
        end
      end
    end

    def get_balance_txn(community, balance_txn_id, account_id)
      with_stripe_payment_config(community) do |payment_settings|
        case destination(community)
        when :platform
          Stripe::BalanceTransaction.retrieve(balance_txn_id)
        when :seller
          Stripe::BalanceTransaction.retrieve(balance_txn_id, {stripe_account: account_id})
        end
      end
    end

    def with_stripe_oauth_config(community, &block)
      with_stripe_payment_config(community) do |payment_settings|
        options = {
          site: 'https://connect.stripe.com',
          authorize_url: '/oauth/authorize',
          token_url: '/oauth/token'
        }
        client_id = payment_settings[:api_client_id]
        api_key = Stripe.api_key
        yield OAuth2::Client.new(client_id, api_key, options)      
      end
    end

    def stripe_connect_url(community, redirect_uri)
      with_stripe_oauth_config(community) do |oauth_client|
        oauth_client.auth_code.authorize_url(scope: 'read_write', redirect_uri: redirect_uri)
      end
    end

    def connect_account_callback(community, auth_code)
      with_stripe_oauth_config(community) do |oauth_client|
        oauth_client.auth_code.get_token(auth_code, :params => {:scope => 'read_write'})
      end
    end

    def update_address(community, account_id, address)
      with_stripe_payment_config(community) do |payment_settings|
        account = Stripe::Account.retrieve(account_id)
        account.legal_entity.address.city = address[:address_city]
        account.legal_entity.address.state = address[:address_state]
        account.legal_entity.address.postal_code = address[:address_postal_code]
        account.legal_entity.address.line1 = address[:address_line1]
        account.save
      end
    end
  end
end
