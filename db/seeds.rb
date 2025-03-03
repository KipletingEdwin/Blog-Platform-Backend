# Clear existing users
User.destroy_all

# Seed sample users
users = [
  { username: "JohnDoe", password: "password123", password_confirmation: "password123" },
  { username: "AliceSmith", password: "securepass", password_confirmation: "securepass" },
  { username: "BobWilliams", password: "mypassword", password_confirmation: "mypassword" },
  { username: "CharlieBrown", password: "test12345", password_confirmation: "test12345" }
]

users.each do |user_data|
  User.create!(user_data) # Make sure it does not reference :name
end

puts "✅ Seeded #{User.count} users successfully!"
