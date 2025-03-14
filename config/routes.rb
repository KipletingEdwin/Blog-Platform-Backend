Rails.application.routes.draw do
  # ✅ Authentication Routes
  post "/signup", to: "auth#signup"
  post "/login", to: "auth#login"

  # ✅ Allow CORS preflight requests (fix OPTIONS error)
  match "/login", to: "auth#login", via: [:options, :post]
  match "/signup", to: "auth#signup", via: [:options, :post]

  # ✅ User Profile Route
  get "/profile", to: "users#profile"

  # ✅ Posts & Comments API Routes
  resources :posts do
    resources :comments, only: [:index, :create]  # Comments are nested under posts
  end

  resources :comments, only: [:destroy, :update]
end
