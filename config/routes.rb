Rails.application.routes.draw do
  post "/signup", to: "auth#signup"
  post "/login", to: "auth#login"

  # ✅ Allow CORS preflight requests (fix OPTIONS error)
  match "/login", to: "auth#login", via: [:options, :post]
  match "/signup", to: "auth#signup", via: [:options, :post]

  get "/profile", to: "users#profile"
end
