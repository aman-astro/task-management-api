class UserMailer < ApplicationMailer
  def reset_password_otp(user)
    @user = user
    @otp = user.reset_password_otp
    mail(to: @user.email, subject: 'Your OTP for Password Reset')
  end
end
