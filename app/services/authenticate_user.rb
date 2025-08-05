class AuthenticateUser
  prepend SimpleCommand

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    return unless user

    JsonWebToken.encode(user_id: user.id)
  end

  private

  attr_accessor :email, :password

  def user
    user = User.find_by(email: email)
    return user if user && user.valid_password?(password)

    errors.add :user_authentication, 'Invalid email or password'
    nil
  end
end