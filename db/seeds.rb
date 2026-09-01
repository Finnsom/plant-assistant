# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Cleaning database..."
Message.destroy_all
Chat.destroy_all
Plant.destroy_all
User.destroy_all

puts "Creating users..."
user1 = User.create!(
  email: "noah@leafy.com",
  password: "password"
)

user2 = User.create!(
  email: "finn@leafy.com",
  password: "password"
)

puts "Creating plants..."
Plant.create!(
  nickname: "Monty",
  species: "Monstera deliciosa",
  location: "Living room",
  last_watered_on: Date.today - 3,
  user: user1
)

Plant.create!(
  nickname: "Sunny",
  species: "Helianthus annuus",
  location: "Balcony",
  last_watered_on: Date.today - 1,
  user: user1
)

Plant.create!(
  nickname: "Spike",
  species: "Cactus",
  location: "Desk",
  last_watered_on: Date.today - 14,
  user: user1
)

Plant.create!(
  nickname: "Fernie",
  species: "Boston Fern",
  location: "Bathroom",
  last_watered_on: Date.today,
  user: user2
)

Plant.create!(
  nickname: "Basil Boss",
  species: "Ocimum basilicum",
  location: "Kitchen windowsill",
  last_watered_on: Date.today - 2,
  user: user2
)

puts "Seeded #{User.count} users and #{Plant.count} plants!"
