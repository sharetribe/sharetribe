[
  "app/utils/service_client/middleware/middleware_base",
  "app/utils/service_client/middleware/param_encoder",
].each { |file| require_relative "../../../../#{file}" }

describe ServiceClient::Middleware::ParamEncoder do

  let(:param_encoder) { ServiceClient::Middleware::ParamEncoder.new }

  it "encodes values" do
    d = DateTime.new(2016, 1, 31, 23, 30, 59)
    params = {
      string_value: "some string",
      num_value: 123,
      date_value: d
    }
    ctx = param_encoder.enter({ req: { params: params }})
    expected = {
      string_value: "some string",
      num_value: "123",
      date_value: "2016-01-31T23:30:59.000Z"
    }
    expect(ctx[:req][:params]).to eq(expected)
  end

  it "is idempotent" do
    d = DateTime.new(2016, 1, 31, 23, 30, 59)
    params = {
      string_value: "some string",
      num_value: 123,
      date_value: d
    }
    ctx_one = param_encoder.enter({ req: { params: params }})
    ctx_two = param_encoder.enter(param_encoder.enter({ req: { params: params }}))

    expect(ctx_two).to eq(ctx_one)
  end

end
