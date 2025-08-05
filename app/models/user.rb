class User < ApplicationRecord
  # Include necessary devise modules
  devise :database_authenticatable, :registerable, :validatable

  has_many :comments, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :tasks, through: :projects

  validates :name, presence: true
  # email validation is handled by Devise :validatable

  # OTP for password reset
  def generate_reset_password_otp!
    self.reset_password_otp = rand(100000..999999).to_s
    self.reset_password_otp_sent_at = Time.current
    save!
  end

  def reset_password_otp_valid?(otp)
    return false if reset_password_otp.blank? || reset_password_otp_sent_at.blank?
    return false if reset_password_otp != otp
    reset_password_otp_sent_at > 10.minutes.ago
  end

  def clear_reset_password_otp!
    self.reset_password_otp = nil
    self.reset_password_otp_sent_at = nil
    save!
  end
end
