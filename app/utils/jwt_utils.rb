#
# A helper module for handling JWT encode/decode
#
# * Fixes some annoyances with the JWT gem, for example that the decode options
# are both strings and symbols (e.g. :verify_sub has to be string, where as
# "sub" has to be string)
#
# * Verifys the subject, mostly for documenting purposes
#
# * "Namespaces" the data to avoid collision with reserved fields, such as `exp` and `sub`
#
# Returns a Result
#

module JWTUtils

  ALGORITHM = "HS256"

  module_function

  def encode(payload, secret, claims = {})
    ensure_secret!(secret)

    exp = Maybe(claims)[:exp].to_i.or_else(nil)
    claims = HashUtils.compact(claims.merge(exp: exp))

    JWT.encode({data: payload}.merge(claims), secret, ALGORITHM)
  end

  def decode(token, secret, claims = {})
    ensure_secret!(secret)

    decode_opts = {
      verify_expiration: true, # always verify expiration
      verify_sub: true,
      algorithm: ALGORITHM
    }

    begin
      decoded = JWT.decode(token, secret, true, decode_opts.merge(claims)).first || {}
      success(decoded["data"])
    rescue JWT::VerificationError
      failure(:verification_error)
    rescue JWT::ExpiredSignature
      failure(:expired_signature)
    rescue JWT::InvalidSubError
      failure(:invalid_sub_error)
    rescue JWT::DecodeError
      # This is basically an else-block
      # DecodeError is the superclass for all other JWT error classes

      # You can add additional exception handlers for each exception
      # To see all the available exceptions, see:
      # https://github.com/jwt/ruby-jwt/blob/ee7c24c4697ebcc050723ca1c0090a865c6788ec/lib/jwt.rb#L12

      failure(:decode_error)
    end
  end

  # private

  def success(data)
    Result::Success.new(data)
  end

  def failure(error)
    Result::Error.new("JWT decoding failed", error)
  end

  def ensure_secret!(secret)
    raise ArgumentError.new("Secret is not specified") if secret.blank?
  end
end
