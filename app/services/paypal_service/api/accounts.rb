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
                                            },
                                            {
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

    ## POST /accounts/create?token=AAAAAAAbDq-HJDXerDtj

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

  end
end
