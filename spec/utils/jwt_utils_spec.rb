require 'spec_helper'

describe JWTUtils do

  let(:secret) { SecureRandom.hex(64) }
  let(:payload) { {"test_data" => true} }

  def expect_success(res, claims = {})
    expect(res.success).to eq(true)
    decoded_data, jwt_meta = res.data
    expect(HashUtils.stringify_keys(payload.merge(claims))).to eq(decoded_data)
  end

  def expect_failure(res, error)
    expect(res.success).to eq(false)
    expect(res[:data]).to eq(error)
  end

  describe "VerificationError" do
    it "success" do
      encoded = JWTUtils.encode(payload, secret)
      decoded = JWTUtils.decode(encoded, secret)
      expect_success(decoded)
    end

    it "failure" do
      encoded = JWTUtils.encode(payload, secret)
      decoded = JWTUtils.decode(encoded, "wrong secret")
      expect_failure(decoded, :verification_error)
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

  describe "ExpiredSignature" do
    it "success" do
      encoded = nil
      exp = nil

      Timecop.freeze(Time.utc(2015, 11, 5, 12, 0, 0)) {
        exp = 1.day.from_now
        encoded = JWTUtils.encode(payload, secret, exp: exp)
      }

      Timecop.freeze(Time.utc(2015, 11, 6, 11, 0, 0)) {
        decoded = JWTUtils.decode(encoded, secret)
        expect_success(decoded)
      }
    end

    it "failure" do
      encoded = nil
      exp = nil

      Timecop.freeze(Time.utc(2015, 11, 5, 12, 0, 0)) {
        exp = 1.day.from_now
        encoded = JWTUtils.encode(payload, secret, exp: exp)
      }

      Timecop.freeze(Time.utc(2015, 11, 6, 13, 0, 0)) {
        decoded = JWTUtils.decode(encoded, secret)
        expect_failure(decoded, :expired_signature)
      }
    end
  end

  describe "InvalidSubError" do
    it "success" do
      encoded = nil

      Timecop.freeze(Time.utc(2015, 11, 5, 12, 0, 0)) {
        encoded = JWTUtils.encode(payload, secret, sub: :__test_sub_1)
      }

      Timecop.freeze(Time.utc(2015, 11, 6, 11, 0, 0)) {
        decoded = JWTUtils.decode(encoded, secret, sub: :__test_sub_1)
        expect_success(decoded)
      }
    end

    it "failure" do
      encoded = nil

      Timecop.freeze(Time.utc(2015, 11, 5, 12, 0, 0)) {
        encoded = JWTUtils.encode(payload, secret, sub: :__test_sub_1)
      }

      Timecop.freeze(Time.utc(2015, 11, 6, 13, 0, 0)) {
        decoded = JWTUtils.decode(encoded, secret, sub: :__test_sub_2)
        expect_failure(decoded, :invalid_sub_error)
      }
    end
  end
end
