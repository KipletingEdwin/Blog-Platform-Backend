class ApplicationController < ActionController::API 
    # before_action :authenticate_request
  
    private
  
    def authenticate_request
      header = request.headers["Authorization"]
      token = header.split(" ").last if header # ✅ Extract Bearer token properly
  
      if token.present?
        begin
          decoded = JsonWebToken.decode(token)
          @current_user = User.find(decoded[:user_id]) if decoded
        rescue JWT::DecodeError
          render json: { error: "Invalid token" }, status: :unauthorized
        rescue ActiveRecord::RecordNotFound
          render json: { error: "User not found" }, status: :unauthorized
        end
      else
        render json: { error: "Unauthorized: Token missing" }, status: :unauthorized
      end
    end

    def current_user
        @current_user
      end
  end
  