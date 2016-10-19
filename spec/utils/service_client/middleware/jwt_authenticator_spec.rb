require 'active_support/all'
require 'uuidtools'
require 'possibly'
require 'jwt'

[
  "app/services/result",
  "app/utils/entity_utils",
  "app/utils/uuid_utils",
  "app/utils/jwt_utils",
  "app/utils/hash_utils",
  "app/utils/service_client/client",
  "app/utils/service_client/middleware/middleware_base",
  "app/utils/service_client/middleware/jwt_authenticator",
].each { |file| require_relative "../../../../#{file}" }

describe ServiceClient::Middleware::JwtAuthenticator do

  SECRET = "secret"

  let(:authenticator) { ServiceClient::Middleware::JwtAuthenticator.new(false, SECRET) }

  def req_token(context)
    context[:req][:headers]["Authorization"].split(" ")[1]
  end

  def token_data(token)
    res = JWTUtils.decode(token, SECRET, verify_sub: false)
    if res.success
      res.data
    end
  end

  it "encodes an authorization header" do
    m_id = UUIDUtils.create
    a_id = UUIDUtils.create
    auth_context = {
      marketplace_id: m_id,
      actor_id: a_id
    }

    ctx = authenticator.enter({req: {headers: {}},
                               opts: {auth_context: auth_context}})
    expect(token_data(req_token(ctx))).to eq({"marketplaceId" => m_id.to_s,
                                              "actorId"       => a_id.to_s})
  end

  it "fails with a missing auth context" do
    ctx = {req: {headers: {}}, opts: {}}
    expect { authenticator.enter(ctx) }.to raise_error(TypeError)
  end

  it "fails with an invalid missing auth context" do
    auth_context = {
      marketplace_id: 1,
      actor_id: 2
    }
    ctx = {req: {headers: {}}, opts: {auth_context: auth_context}}
    expect { authenticator.enter(ctx) }.to raise_error(ArgumentError)
  end

end
