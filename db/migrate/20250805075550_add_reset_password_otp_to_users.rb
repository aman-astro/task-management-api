class AddResetPasswordOtpToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :reset_password_otp, :string
    add_column :users, :reset_password_otp_sent_at, :datetime
  end
end
