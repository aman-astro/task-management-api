class JsonWebToken
  class << self
    # Central place to fetch the JWT HMAC secret.
    # Falls back to Rails.secret_key_base in development/test.
    def secret_key
      secret_key = ENV["JWT_SECRET"]
      if secret_key.blank?
        if Rails.env.development? || Rails.env.test?
          Rails.application.secret_key_base
        else
          raise "JWT_SECRET environment variable is not set"
        end
      else
        secret_key
      end
    end

    def encode(payload, exp = 12.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, secret_key)
    end

    def decode(token)
      body = JWT.decode(token, secret_key)[0]
      HashWithIndifferentAccess.new(body)
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end
  end
end