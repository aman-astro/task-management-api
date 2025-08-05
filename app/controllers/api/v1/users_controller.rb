class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /api/v1/users
  def index
    @users = User.all
    render_success(
      @users.map { |user| UserSerializer.new(user) },
      'Users retrieved successfully'
    )
  end

  # GET /api/v1/users/:id
  def show
    render_success(
      UserSerializer.new(@user),
      'User retrieved successfully'
    )
  end

  # PATCH/PUT /api/v1/users/:id
  def update
    if @user.update(user_params)
      render_success(
        UserSerializer.new(@user),
        'User updated successfully'
      )
    else
      render_error(
        'User update failed',
        @user.errors.full_messages,
        :unprocessable_entity
      )
    end
  end

  # DELETE /api/v1/users/:id
  def destroy
    @user.destroy
    render_success(
      nil,
      'User deleted successfully'
    )
  end

  # POST /api/v1/users/forgot_password
  def forgot_password
    user = User.find_by(email: params[:user_email])
    if user
      user.generate_reset_password_otp!
      UserMailer.reset_password_otp(user).deliver_later
      render_success(nil, 'OTP sent to your email')
    else
      render_not_found('User not found')
    end
  end

  # POST /api/v1/users/reset_password
  def reset_password
    user = User.find_by(email: params[:user_email])
    if user && user.reset_password_otp_valid?(params[:otp])
      if params[:new_password].present? && params[:new_password] == params[:confirm_new_password]
        user.password = params[:new_password]
        user.clear_reset_password_otp!
        if user.save
          render_success(nil, 'Password has been reset successfully')
        else
          render_error('Failed to reset password', user.errors.full_messages)
        end
      else
        render_error('Passwords do not match or are blank')
      end
    else
      render_error('Invalid OTP or OTP expired')
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    render_not_found('User not found') unless @user
  end

  def user_params
    params.require(:user).permit(:name)
  end
end