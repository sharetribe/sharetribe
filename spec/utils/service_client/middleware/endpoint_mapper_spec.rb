[
  "app/utils/service_client/middleware/middleware_base",
  "app/utils/service_client/middleware/endpoint_mapper",
].each { |file| require_relative "../../../../#{file}" }

describe ServiceClient::Middleware::EndpointMapper do

  let(:endpoint_map) {
    { show: "/show" }
  }

  let(:endpoint_mapper) { ServiceClient::Middleware::EndpointMapper.new(endpoint_map) }

  it "maps endpoint name to path" do
    expect(endpoint_mapper.enter(req: {}, endpoint: :show))
      .to include(req: { path: "/show"})
  end

  it "throws if endpoint is not found" do
    expect { endpoint_mapper.enter(req: {}, endpoint: :unknown_endpoint) }
      .to raise_error(ArgumentError)
  end
end
