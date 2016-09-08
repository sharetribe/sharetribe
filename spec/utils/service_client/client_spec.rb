[
  "app/utils/service_client/context_runner",
  "app/utils/service_client/client",
  "app/services/result",
].each { |file| require_relative "../../../#{file}" }

describe ServiceClient::Client do

  module FakeHTTPClient
    module_function

    def enter(ctx)
      endpoint = ctx.fetch(:params).fetch(:url)
      case endpoint
      when "/show"
        ctx.merge(
          res: {
            status: 200,
            success: true,
            body: "",
            headers: {}
          }
        )
      when "/error"
        ctx.merge(
          res: {
            status: 500,
            success: false,
            body: "Internal server error",
            headers: {}
          }
        )
      else
        raise ArgumentError.new("Unknown endpoint: '#{endpoint}'")
      end
    end

    def leave(ctx)
      ctx
    end

    def error(ctx)
      ctx
    end
  end

  describe "#get" do

    let(:endpoints) {
      {
        show: "/show",
        create: "/create",
        error: "/error"
      }
    }

    let(:client) {
      ServiceClient::Client.new(endpoints, [], FakeHTTPClient)
    }

    it "throws an exception if endpoint is not found" do
      expect { client.get(:notfound) }.to raise_error(ArgumentError)
    end

    it "returns Success" do
      res = client.get(:show)
      expect(res).to be_a(Result::Success)
      expect(res[:data][:body]).to eq("")
      expect(res[:data][:status]).to eq(200)
    end

    it "returns Error" do
      res = client.get(:error)
      expect(res).to be_a(Result::Error)
      expect(res[:data][:body]).to eq("Internal server error")
      expect(res[:data][:status]).to eq(500)
    end

  end

end
