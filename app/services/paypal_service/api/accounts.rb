module PaypalService::API
  PaypalAccountStore = PaypalService::Store::PaypalAccount

  class Accounts
    include PaypalService::PermissionsInjector

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
          account = PaypalAccountStore.update({
                                                community_id: community_id,
                                                person_id: person_id,
                                                email: personal_data[:email],
                                                payer_id: personal_data[:payer_id],
                                                verification_code: body[:verification_code],
                                                scope: access_token[:scope].join(',')
                                              })

          Result::Success.new(account)
        }
      }
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

  end
end
