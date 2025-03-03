class ApplicationController < ActionController::API 
    # before_action :authenticate_request


    private

    def authenticate_request 
        header = request.headers["Authorization"]
        token = header.split("").last if header
        decoded = JsonWebToken.decode(token)
        @current_user = User.find(decoded[:user_id]) if decoded 
    rescue

        render json: { error: "Unauthorized"}, status: :unauthorized
    end
end
