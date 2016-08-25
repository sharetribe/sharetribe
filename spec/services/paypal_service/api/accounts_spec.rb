require 'spec_helper'

describe PaypalService::API::Accounts do

  APIDataTypes = PaypalService::API::DataTypes

  ## API Operations (with default test data)
  def request_personal_account(email: nil, payer_id: nil, flow: :old)
    email ||= @email
    payer_id ||= @payer_id

    @accounts.request(
      body: APIDataTypes.create_create_account_request(
      {
        community_id: @cid,
        person_id: @mid,
        # For testing purposes, add 'email' and 'payer_id' query params.
        # That way we can inject them to our fake PayPal
        callback_url: "https://test.com/request?email=#{email}&payer_id=#{payer_id}",
        country: @country
      }),
      flow: flow)
  end

  def request_community_account(email: nil, payer_id: nil, flow: :old)
    email ||= @email
    payer_id ||= @payer_id

    response = @accounts.request(
      body: APIDataTypes.create_create_account_request(
      {
        community_id: @cid,
        # For testing purposes, add 'email' and 'payer_id' query params.
        # That way we can inject them to our fake PayPal
        callback_url: "https://test.com/request?email=#{email}&payer_id=#{payer_id}",
        country: @country
      }),
      flow: flow)
  end

  def create_personal_account(request_response)
    _, token = parse_redirect_url_from_response(request_response)

    @accounts.create(
      community_id: @cid,
      person_id: @mid,
      order_permission_request_token: token,
      body: {
        order_permission_verification_code: "xxxxyyyyzzzz"
      },
      flow: :old)
  end

  def create_personal_account_new_flow(response_payer_id: nil, request:)
    payer_id = response_payer_id || @payer_id

    @accounts.create(
      community_id: @cid,
      person_id: @mid,
      order_permission_request_token: nil,
      body: { onboarding_params:
                {"merchantId"=> request[:data][:onboarding_params][:merchantId],
                 "merchantIdInPayPal"=> payer_id,
                 "permissionsGranted"=> "true",
                 "accountStatus"=> "BUSINESS_ACCOUNT",
                 "consentStatus"=> "false",
                 "productIntentID"=> "addipmt",
                 "isEmailConfirmed"=> "false",
                 "returnMessage"=> "To start accepting payments, please log in to PayPal and finish signing up.",
                }},
      flow: :new)
  end

  def create_community_account(request_response)
    _, token = parse_redirect_url_from_response(request_response)

    @accounts.create(
      community_id: @cid,
      order_permission_request_token: token,
      body: {
        order_permission_verification_code: "xxxxyyyyzzzz"
      },
      flow: :old)
  end

  def create_community_account_new_flow(response_payer_id: nil, request:)
    payer_id = response_payer_id || @payer_id

    @accounts.create(
      community_id: @cid,
      order_permission_request_token: nil,
      body: { onboarding_params:
                {"merchantId"=> request[:data][:onboarding_params][:merchantId],
                 "merchantIdInPayPal"=> payer_id,
                 "permissionsGranted"=> "true",
                 "accountStatus"=> "BUSINESS_ACCOUNT",
                 "consentStatus"=> "false",
                 "productIntentID"=> "addipmt",
                 "isEmailConfirmed"=> "false",
                 "returnMessage"=> "To start accepting payments, please log in to PayPal and finish signing up.",
                }},
      flow: :new)
  end

  def request_billing_agreement
    @accounts.billing_agreement_request(
      community_id: @cid,
      person_id: @mid,
      body: {
        description: "Let marketplace X take commissions",
        success_url: "https://test.com/billing_agreement/success",
        cancel_url: "https://test.com/billing_agreement/cancel"
      }
    )
  end

  def create_billing_agreement(token)
    response = @accounts.billing_agreement_create(
      community_id: @cid,
      person_id: @mid,
      billing_agreement_request_token: token
    )
  end

  def delete_billing_agreement
    @accounts.delete_billing_agreement(
      community_id: @cid,
      person_id: @mid
    )
  end

  def delete_personal_account
    @accounts.delete(
      community_id: @cid,
      person_id: @mid
    )
  end

  def delete_community_account
    @accounts.delete(
      community_id: @cid
    )
  end

  def get_personal_account
    @accounts.get(
      community_id: @cid,
      person_id: @mid
    )
  end

  def get_community_account
    @accounts.get(
      community_id: @cid
    )
  end

  ## Helpers

  # Takes a callback URL and returns parsed version, that is, a tuple of URL
  # without query part and the token
  #
  # https://<what_ever>?token=<36 chars length token>
  #
  # Example: https://paypaltest.com/billing_agreement?token=3252be6f-e606-41df-a3b7-3eae625be9ac
  #
  # Returs: ["https://paypaltest.com/billing_agreement", "3252be6f-e606-41df-a3b7-3eae625be9ac"]
  def parse_redirect_url(url)
    uri = URI(url)

    token = Maybe(URI(url).query).map { |query_string|
      Maybe(CGI.parse(query_string)["token"]).map { |token_value_array|
        token_value_array.first
      }.or_else(nil)
    }.or_else(nil)

    path_without_query = "#{uri.scheme}://#{uri.host}#{uri.path}"

    [path_without_query, token]
  end

  def parse_redirect_url_from_response(res)
    parse_redirect_url(res[:data][:redirect_url])
  end

  def expect_token(token)
    expect(token).to be_a String
    expect(token.length).to eq 36
  end

  def expect_success(res)
    expect(res[:success]).to eq true
  end

  def expect_no_personal_account
    with_success(get_personal_account) { |data|
      expect(data).to be_nil
    }
  end

  def expect_no_community_account
    with_success(get_personal_account) { |data|
      expect(data).to be_nil
    }
  end

  def with_success(res, &block)
    expect_success(res)
    block.call(res[:data])
    res[:data]
  end

  def with_personal_account(&block)
    with_success(get_personal_account) { |data|
      expect(data[:community_id]).to eq @cid
      expect(data[:person_id]).to eq @mid

      block.call(data)
    }
  end

  def with_community_account(&block)
    with_success(get_community_account) { |data|
      expect(data[:community_id]).to eq @cid
      expect(data[:person_id]).to eq nil

      block.call(data)
    }
  end

  before(:each) do
    # Test version of merchant and permission clients
    PaypalService::API::Api.reset!
    @api_builder = PaypalService::API::Api.api_builder
    @accounts = PaypalService::API::Api.build_test_accounts(prepend_country_code: true)

    # Test data

    @cid = 10
    @mid = "merchant_id_1"
    @country = "gb"
    @payer_id = "payer_id"
    @new_payer_id = "new_payer_id"
    @email = "payer_email@example.com"
    @new_email = "new_payer_email@example.com"
  end

  context "#request" do

    it "creates pending personal account" do
      response = request_personal_account

      with_success(response) { |data|
        redirect_endpoint, token = parse_redirect_url(data[:redirect_url])
        expect(redirect_endpoint).to eq "https://test.com/gb/request"
        expect_token(token)
      }
    end

    it "creates pending community account" do
      response = request_community_account

      with_success(response) { |data|
        redirect_endpoint, token = parse_redirect_url(data[:redirect_url])
        expect(redirect_endpoint).to eq "https://test.com/gb/request"
        expect_token(token)
      }
    end

    it "creates pending personal account, new flow" do
      response = request_personal_account(flow: :new)
      expect(response[:success]).to eq true
    end

    it "creates pending community account, new flow" do
      response = request_community_account(flow: :new)
      expect(response[:success]).to eq true
    end

  end

  describe "#create" do

    context "personal account" do
      it "creates personal account with permissions" do
        res = request_personal_account
        create_personal_account(res)

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :connected
          expect(data[:email]).to eq @email
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }
      end

      it "creates personal account with permissions, new flow" do
        res = request_personal_account(flow: :new)
        response = create_personal_account_new_flow(request: res)

        expect(response[:success]).to eq true

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :connected
          expect(data[:email]).to eq nil
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }
      end

      it "replaces old unverified account" do
        res = request_personal_account
        expect_no_personal_account
        res2 = request_personal_account(email: @new_email, payer_id: @new_payer_id)
        create_personal_account(res2)

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :connected
          expect(data[:email]).to eq @new_email
          expect(data[:payer_id]).to eq @new_payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }

      end

      it "replaces old unverified account, new flow" do
        res = request_personal_account(flow: :new)
        expect_no_personal_account
        res2 = request_personal_account(flow: :new)
        create_personal_account_new_flow(request: res2, response_payer_id: @new_payer_id)

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :connected
          expect(data[:payer_id]).to eq @new_payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }
      end

      it "replaces old verified account with new one" do
        res = request_personal_account
        create_personal_account(res)

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :connected
          expect(data[:email]).to eq @email
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }

        res = request_personal_account(email: @new_email, payer_id: @new_payer_id)

        # Returns old account as long as the new account does not have permissions verified
        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :connected
          expect(data[:email]).to eq @email
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }

        create_personal_account(res)

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :connected
          expect(data[:email]).to eq @new_email
          expect(data[:payer_id]).to eq @new_payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }
      end

      it "replaces old verified account with new one, new flow" do
        res = request_personal_account(flow: :new)
        create_personal_account_new_flow(request: res)

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :connected
          expect(data[:email]).to eq nil
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }

        res = request_personal_account(flow: :new)

        # Returns old account as long as the new account does not have permissions verified
        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :connected
          expect(data[:email]).to eq nil
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }

        create_personal_account_new_flow(request: res, response_payer_id: @new_payer_id)

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :connected
          expect(data[:email]).to eq nil
          expect(data[:payer_id]).to eq @new_payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }
      end

      it "uses existing account if it's reconnected" do
        # Account A
        res = request_personal_account
        create_personal_account(res)
        res = request_billing_agreement
        _, token = parse_redirect_url_from_response(res)
        create_billing_agreement(token)

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :verified
          expect(data[:email]).to eq @email
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :verified
        }

        # Account B
        res = request_personal_account(email: @new_email, payer_id: @new_payer_id)
        create_personal_account(res)

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :connected
          expect(data[:email]).to eq @new_email
          expect(data[:payer_id]).to eq @new_payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }

        # Reactivate Account A
        res = request_personal_account
        create_personal_account(res)

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :verified
          expect(data[:email]).to eq @email
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :verified
        }
      end

      it "uses existing account if it's reconnected, new flow" do
        # Account A
        res = request_personal_account(flow: :new)
        create_personal_account_new_flow(request: res, response_payer_id: @payer_id)
        res = request_billing_agreement
        _, token = parse_redirect_url_from_response(res)
        create_billing_agreement(token)

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :verified
          expect(data[:email]).to eq nil
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :verified
        }

        # Account B
        res = request_personal_account(flow: :new)
        create_personal_account_new_flow(request: res, response_payer_id: @new_payer_id)

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :connected
          expect(data[:email]).to eq nil
          expect(data[:payer_id]).to eq @new_payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }

        # Reactivate Account A
        res = request_personal_account(flow: :new)
        create_personal_account_new_flow(request: res, response_payer_id: @payer_id)

        with_personal_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :verified
          expect(data[:email]).to eq nil
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :verified
        }
      end
    end

    context "community account" do
      it "creates community account with permissions" do
        res = request_community_account
        create_community_account(res)

        with_community_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :verified
          expect(data[:email]).to eq @email
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }
      end

      it "creates community account with permissions, new flow" do
        res = request_community_account(flow: :new)
        create_community_account_new_flow(request: res)

        with_community_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :verified
          expect(data[:email]).to eq nil
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }
      end

      it "replaces old account with new one" do
        res = request_community_account
        create_community_account(res)

        with_community_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :verified
          expect(data[:email]).to eq @email
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }

        res = request_community_account(email: @new_email, payer_id: @new_payer_id)

        # Returns old account as long as the new account does not have permissions verified
        with_community_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :verified
          expect(data[:email]).to eq @email
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }

        create_community_account(res)

        with_community_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :verified
          expect(data[:email]).to eq @new_email
          expect(data[:payer_id]).to eq @new_payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }
      end

      it "replaces old account with new one, new flow" do
        res = request_community_account(flow: :new)
        create_community_account_new_flow(request: res, response_payer_id: @payer_id)

        with_community_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :verified
          expect(data[:email]).to eq nil
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }

        res = request_community_account(flow: :new)

        # Returns old account as long as the new account does not have permissions verified
        with_community_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :verified
          expect(data[:email]).to eq nil
          expect(data[:payer_id]).to eq @payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }

        create_community_account_new_flow(request: res, response_payer_id: @new_payer_id)

        with_community_account { |data|
          expect(data[:active]).to eq true
          expect(data[:state]).to eq :verified
          expect(data[:email]).to eq nil
          expect(data[:payer_id]).to eq @new_payer_id
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }
      end
    end
  end

  context "#get" do

    it "does not return inactive account" do
      request_personal_account
      expect_no_personal_account
    end

  end

  context "#billing_agreement_request" do

    it "creates billing agreement request" do
      res = request_personal_account
      create_personal_account(res)
      response = request_billing_agreement

      with_success(response) { |data|
        redirect_endpoint, token = parse_redirect_url(data[:redirect_url])
        expect(redirect_endpoint).to eq "https://test.com/billing_agreement/success"
        expect_token(token)
      }

      with_personal_account { |data|
        expect(data[:active]).to eq true
        expect(data[:state]).to eq :connected
        expect(data[:email]).to eq @email
        expect(data[:payer_id]).to eq @payer_id
        expect(data[:order_permission_state]).to eq :verified
        expect(data[:billing_agreement_state]).to eq :pending
      }
    end
  end

  context "#billing_agreement_create" do

    it "verifies billing agreement" do
      res = request_personal_account
      create_personal_account(res)
      res = request_billing_agreement
      _, token = parse_redirect_url_from_response(res)
      create_billing_agreement(token)

      with_personal_account { |data|
        expect(data[:active]).to eq true
        expect(data[:state]).to eq :verified
        expect(data[:email]).to eq @email
        expect(data[:payer_id]).to eq @payer_id
        expect(data[:order_permission_state]).to eq :verified
        expect(data[:billing_agreement_state]).to eq :verified
        expect_token(data[:billing_agreement_billing_agreement_id])
      }
    end
  end

  context "#delete_billing_agreement" do

    it "deletes pending billing agreement" do
      res = request_personal_account
      create_personal_account(res)
      request_billing_agreement

      with_personal_account { |data|
        expect(data[:billing_agreement_state]).to eq :pending
      }

      expect_success(delete_billing_agreement)

      with_personal_account { |data|
        expect(data[:billing_agreement_state]).to eq :not_verified
      }
    end

    it "deletes verified billing agreement" do
      res = request_personal_account
      create_personal_account(res)
      res = request_billing_agreement
      _, token = parse_redirect_url_from_response(res)
      create_billing_agreement(token)

      with_personal_account { |data|
        expect(data[:billing_agreement_state]).to eq :verified
      }

      expect_success(delete_billing_agreement)

      with_personal_account { |data|
        expect(data[:billing_agreement_state]).to eq :not_verified
      }
    end
  end

  describe "#delete" do
    context "personal account" do

      it "deletes account with verified permissions" do
        res = request_personal_account
        create_personal_account(res)

        with_personal_account { |data|
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }

        expect_success(delete_personal_account)
        expect_no_personal_account
      end

      it "deletes account with pending billing agreement" do
        res = request_personal_account
        create_personal_account(res)
        request_billing_agreement

        with_personal_account { |data|
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :pending
        }

        expect_success(delete_personal_account)
        expect_no_personal_account
      end

      it "deletes account with verified billing agreement" do
        res = request_personal_account
        create_personal_account(res)
        res = request_billing_agreement
        _, token = parse_redirect_url_from_response(res)
        create_billing_agreement(token)

        with_personal_account { |data|
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :verified
        }

        expect_success(delete_personal_account)
        expect_no_personal_account
      end
    end

    context "community account" do
      it "deletes account with verified permissions" do
        res = request_community_account
        create_community_account(res)

        with_community_account { |data|
          expect(data[:order_permission_state]).to eq :verified
          expect(data[:billing_agreement_state]).to eq :not_verified
        }

        expect_success(delete_community_account)
        expect_no_community_account
      end
    end
  end
end
