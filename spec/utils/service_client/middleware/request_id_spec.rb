[
  "app/utils/service_client/middleware/middleware_base",
  "app/utils/service_client/middleware/request_id",
].each { |file| require_relative "../../../../#{file}" }

describe ServiceClient::Middleware::RequestID do

  let(:request_id) { ServiceClient::Middleware::RequestID.new }

  it "adds request ID header" do
    ctx = request_id.enter(req: { headers: {}})
    request_id_header = ctx.dig(:req, :headers, "X-Request-Id")

    # http://stackoverflow.com/questions/136505/searching-for-uuids-in-text-with-regex
    uuid_regexp = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

    expect(request_id_header).to match(uuid_regexp)
  end
end
