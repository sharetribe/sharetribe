require 'spec_helper'

describe ServiceClient::Middleware::BodyEncoder do

  let(:body_encoder) { ServiceClient::Middleware::BodyEncoder }

  describe "JSONEncoder" do

    let(:json_encoder) { body_encoder.new(:json) }

    it "#enter" do
      ctx = json_encoder.enter(req: { body: {"a" => 1}, headers: {}})

      expect(JSON.parse(ctx[:req][:body])).to eq({"a" => 1})
      expect(ctx[:req][:headers]).to include(
                                       "Accept" => "application/json",
                                       "Content-Type" => "application/json",
                                     )
    end

    it "#leave" do
      ctx = json_encoder.leave(res: { body: {"a" => 1}.to_json })

      expect(ctx[:res][:body]).to eq({"a" => 1})
    end
  end
end
