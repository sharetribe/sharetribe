require 'spec_helper'

describe JWTUtils do

  let(:secret) { SecureRandom.hex(64) }

  context "success" do

    it "encodes and decodes successfully" do
      payload = {"test_data" => true}
      encoded = JWTUtils.encode(payload, secret)
      decode_result = JWTUtils.decode(encoded, secret)
      expect(decode_result.success).to eq(true)
      decoded_data, jwt_meta = decode_result.data
      expect(payload).to eq(decoded_data)
    end
  end

  context "failure" do
    it "handles VerificationError" do
      payload = {"test_data" => true}
      encoded = JWTUtils.encode(payload, secret)
      decode_result = JWTUtils.decode(encoded, "some secret")
      expect(decode_result.success).to eq(false)
      expect(decode_result.data[:error_code]).to eq(:verification_error)
    end

    it "throws if secret is empty" do
      payload = {"test_data" => true}

      expect {
        JWTUtils.encode(payload, "")
      }.to raise_error(ArgumentError, "Secret is not specified")

      expect {
        JWTUtils.decode("encoded jwt token", "")
      }.to raise_error(ArgumentError, "Secret is not specified")

    end
  end
end
