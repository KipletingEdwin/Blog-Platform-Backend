class AuthController < ApplicationController

  require Rails.root.join('lib/json_web_token')
  require 'json_web_token'


  # ✅ Sign up new users
  def signup
    user = User.new(user_params)
    if user.save
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, user: { id: user.id, username: user.username } }, status: :created
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ✅ Login action (Fixes the missing method)
  def login
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])  # Authenticate user
      token = JsonWebToken.encode(user_id: user.id)  # Generate JWT token
      render json: { token: token, user: { id: user.id, username: user.username } }, status: :ok
    else
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:username, :password, :password_confirmation)
  end
end
