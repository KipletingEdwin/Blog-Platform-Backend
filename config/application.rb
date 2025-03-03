require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module MyMarch
  class Application < Rails::Application
    # ✅ Initialize configuration defaults for Rails 8
    config.load_defaults 8.0
    config.eager_load_paths << Rails.root.join("lib")

    # ✅ Fix: Ensure config is inside the Application class
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'http://localhost:5173'  # Adjust based on your frontend URL
        resource '*',
                 headers: :any,
                 methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end

    # ✅ Ensure API-only mode is set correctly
    config.api_only = true
  end
end
