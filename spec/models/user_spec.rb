require 'rails_helper'

describe User, type: :model do
  context 'validations' do
    it { should validate_presence_of(:name) }
    # Devise handles email presence/format/uniqueness
  end

  context 'associations' do
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:projects).dependent(:destroy) }
    it { should have_many(:tasks).through(:projects) }
  end

  describe '#generate_reset_password_otp!' do
    it 'generates a 6-digit OTP and sets sent_at' do
      user = User.create!(name: 'Test', email: 'test@example.com', password: 'password123')
      user.generate_reset_password_otp!
      expect(user.reset_password_otp).to match(/\A\d{6}\z/)
      expect(user.reset_password_otp_sent_at).to be_within(1.second).of(Time.current)
    end
  end

  describe '#reset_password_otp_valid?' do
    let(:user) { User.create!(name: 'Test', email: 'test2@example.com', password: 'password123') }
    before { user.generate_reset_password_otp! }

    it 'returns true for correct OTP within 10 minutes' do
      expect(user.reset_password_otp_valid?(user.reset_password_otp)).to be true
    end

    it 'returns false for incorrect OTP' do
      expect(user.reset_password_otp_valid?('000000')).to be false
    end

    it 'returns false if OTP expired' do
      user.update!(reset_password_otp_sent_at: 11.minutes.ago)
      expect(user.reset_password_otp_valid?(user.reset_password_otp)).to be false
    end
  end

  describe '#clear_reset_password_otp!' do
    it 'clears the OTP and sent_at fields' do
      user = User.create!(name: 'Test', email: 'test3@example.com', password: 'password123')
      user.generate_reset_password_otp!
      user.clear_reset_password_otp!
      expect(user.reset_password_otp).to be_nil
      expect(user.reset_password_otp_sent_at).to be_nil
    end
  end
end