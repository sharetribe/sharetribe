[
  "app/utils/service_client/middleware/middleware_base",
  "app/utils/service_client/middleware/timeout",
].each { |file| require_relative "../../../../#{file}" }

describe ServiceClient::Middleware::Timeout do

  let(:timeout) { ServiceClient::Middleware::Timeout.new }

  it "adds default timeout" do
    ctx = timeout.enter({req: {}})
    expect(ctx[:req]).to include(timeout: 5, open_timeout: 2)
  end
end
