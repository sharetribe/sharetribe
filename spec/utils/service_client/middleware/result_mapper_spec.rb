[
  "app/utils/service_client/middleware/middleware_base",
  "app/utils/service_client/middleware/result_mapper",
  "app/services/result",
].each { |file| require_relative "../../../../#{file}" }

describe ServiceClient::Middleware::ResultMapper do

  let(:result_mapper) { ServiceClient::Middleware::ResultMapper.new }

  describe "#leave" do
    it "returns Success if request was successful" do
      expect(result_mapper.leave(res: { success: true })[:res])
        .to be_a(Result::Success)
    end

    it "returns Error if request was successful" do
      expect(result_mapper.leave(res: { success: false })[:res])
        .to be_a(Result::Error)
    end
  end

  describe "#error" do
    it "returns Error is middleware processing errored" do
      expect(result_mapper.error({})[:res])
        .to be_a(Result::Error)
    end
  end
end
