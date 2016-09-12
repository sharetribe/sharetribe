require_relative "../../app/utils/http_utils"
require 'active_support/core_ext/object'

describe HTTPUtils do

  describe "#parse_content_type" do
    it "returns nil if content type doesn't exist or is blank" do
      expect(HTTPUtils.parse_content_type(nil)).to eq(nil)
      expect(HTTPUtils.parse_content_type("")).to eq(nil)

    end

    it "returns the media type" do
      expect(HTTPUtils.parse_content_type("application/json")).to eq("application/json")
    end

    it "lowercases the result" do
      expect(HTTPUtils.parse_content_type("application/JSON")).to eq("application/json")
    end

    it "ignores the parameters" do
      expect(HTTPUtils.parse_content_type("application/transit+msgpack;charset=UTF-8")).to eq("application/transit+msgpack")
    end

    it "trims the result" do
      expect(HTTPUtils.parse_content_type("   application/transit+msgpack ; charset=UTF-8")).to eq("application/transit+msgpack")
    end
  end
end
