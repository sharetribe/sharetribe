module JWTUtils

  module_function

  def encode(payload, secret)
    JWT.encode(payload, secret)
  end

  def decode(token, secret)
    begin
      result(JWT.decode(token, secret, true), nil)
    rescue JWT::VerificationError
      result(nil, :verification_error)
    rescue JWT::DecodeError
      # You can add additional exception handlers for each exception
      # To see all the available exceptions, see:
      # https://github.com/jwt/ruby-jwt/blob/ee7c24c4697ebcc050723ca1c0090a865c6788ec/lib/jwt.rb#L12
      result(nil, :decode_error)
    end
  end

  # private

  def result(decoded, error = nil)
    if error.nil?
      Result::Success.new(decoded)
    else
      Result::Error.new({error_code: error})
    end
  end

end
