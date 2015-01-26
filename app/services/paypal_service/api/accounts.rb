module PaypalService::API
  PaypalAccountStore = PaypalService::Store::PaypalAccount

  class Accounts
    include PaypalService::PermissionsInjector
    include PaypalService::MerchantInjector

    # The API implmenetation
    #

    ## POST /accounts/request
    def request(opts)
      with_permission_request_response(opts[:callback_url]) { |perm_req_response|
        account = PaypalAccountStore.create({
                                              community_id: opts[:community_id],
                                              person_id: opts[:person_id],
                                              request_token: perm_req_response[:request_token],
                                              paypal_username_to: perm_req_response[:username_to]
                                            })

        redirect_url = URLUtils.prepend_path_component(perm_req_response[:redirect_url], opts[:country])

        Result::Success.new(DataTypes.create_account_request({
                                                               community_id: opts[:community_id],
                                                               person_id: opts[:person_id],
                                                               redirect_url: redirect_url
                                                             }))
      }
    end

    ## TODO

    ## POST /accounts/request/cancel?token=AAAAAAAbDq-HJDXerDtj

    ## POST /accounts/:community_id/:person_id/create?token=AAAAAAAbDq-HJDXerDtj&verification_code=xxxxx11112222

    def create(community_id, person_id, request_token, body)
      with_access_token(request_token, body[:verification_code]) { |access_token|
        with_personal_data(access_token[:token], access_token[:token_secret]) { |personal_data|
          account = PaypalAccountStore.update(
            {
              community_id: community_id,
              person_id: person_id,
              email: personal_data[:email],
              payer_id: personal_data[:payer_id],
              verification_code: body[:verification_code],
              scope: access_token[:scope].join(','),
              active: person_id.nil? # activate admin account
            })

          Result::Success.new(account)
        }
      }
    end

    ## POST /accounts/:community_id/:person_id/billing_agreement/request
    #
    # Body:
    # { description: "Let marketplace take commission"
    # , success_url: "http://marketplace.com/success
    # , cancel_url: "http://marketplace.com/cancel
    # }
    #

    def billing_agreement_request(community_id, person_id, body)
      with_billing_agreement_request(body[:description], body[:success_url], body[:cancel_url]) { |billing_agreement_request|
        account = PaypalAccountStore.update({
                                              community_id: community_id,
                                              person_id: person_id,
                                              billing_agreement_paypal_username_to: billing_agreement_request[:username_to],
                                              billing_agreement_request_token: billing_agreement_request[:token]
                                            })

        Result::Success.new(DataTypes.create_billing_agreement_request({
                                                                         redirect_url: billing_agreement_request[:redirect_url]
                                                                       }))
      }
    end

    ## POST /accounts/:community_id/:person_id/billing_agreement/create?token=EC-123215122362
    #
    # Empty body
    #
    # Errors:
    #
    # - :billing_agreement_not_accepted
    # - :wrong_account

    def billing_agreement_create(community_id, person_id, request_token)
      paypal_account = PaypalAccountStore.get(person_id, community_id)

      with_billing_agreement(request_token) { |billing_agreement|
        with_express_checkout_details(request_token) { |express_checkout_details|
          if !express_checkout_details[:billing_agreement_accepted]
            Result::Error.new(:billing_agreement_not_accepted)
          elsif express_checkout_details[:payer_id] != paypal_account[:payer_id]
            Result::Error.new(:wrong_account)
          else
            account = PaypalAccountStore.update(
              {
                community_id: community_id,
                person_id: person_id,
                billing_agreement_id: billing_agreement[:billing_agreement_id],
                active: true
              })

            Result::Success.new(account)
          end
        }

      }
    end

    def delete_billing_agreement(community_id=nil, person_id=nil, payer_id=nil)
      PaypalAccountStore.delete_billing_agreement(
        {
          person_id: person_id,
          community_id: community_id,
          payer_id: payer_id
        })

      Result::Success.new()
    end

    ## GET /accounts/:community_id(/:person_id?)

    private

    def with_permission_request_response(callback_url, &block)
      permission_request = PaypalService::DataTypes::Permissions
                           .create_req_perm({callback: callback_url })

      response = paypal_permissions.do_request(permission_request)

      if response[:success]
        block.call(response)
      else
        nil
      end
    end

    def with_access_token(request_token, verification_code, &block)
      access_token_request = PaypalService::DataTypes::Permissions
                             .create_get_access_token({request_token: request_token, verification_code: verification_code})

      response = paypal_permissions.do_request(access_token_request)

      if response[:success]
        block.call(response)
      else
        nil
      end
    end

    def with_personal_data(access_token, access_token_secret, &block)
      personal_data_request = PaypalService::DataTypes::Permissions
                              .create_get_basic_personal_data({token: access_token, token_secret: access_token_secret})

      response = paypal_permissions.do_request(personal_data_request)

      if response[:success]
        block.call(response)
      else
        nil
      end
    end

    def with_billing_agreement_request(description, success_url, cancel_url, &block)
      billing_agreement_request = PaypalService::DataTypes::Merchant
                                  .create_setup_billing_agreement({
                                                                    description: description,
                                                                    success: success_url,
                                                                    cancel: cancel_url
                                                                  })

      response = paypal_merchant.do_request(billing_agreement_request)

      if response[:success]
        block.call(response)
      else
        nil
      end
    end

    def with_billing_agreement(request_token, &block)
      billing_agreement_request = PaypalService::DataTypes::Merchant
                                  .create_create_billing_agreement({
                                                                     token: request_token
                                                                   })

      response = paypal_merchant.do_request(billing_agreement_request)

      if response[:success]
        block.call(response)
      else
        nil
      end
    end

    def with_express_checkout_details(request_token, &block)
      express_checkout_details_request = PaypalService::DataTypes::Merchant
                                         .create_get_express_checkout_details({
                                                                                token: request_token
                                                                              })

      response = paypal_merchant.do_request(express_checkout_details_request)

      if response[:success]
        block.call(response)
      else
        nil
      end
    end

  end
end
