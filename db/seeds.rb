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

fernie = Plant.create!(
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

puts "Creating a past conversation..."
fernie_chat = Chat.create!(
  title: "The leaf tips have gone brown and crispy",
  user: user2,
  plant: fernie
)

fernie_chat.messages.create!(
  role: "user",
  content: "The leaf tips have gone brown and crispy"
)

fernie_chat.messages.create!(
  role: "assistant",
  content: "Crispy brown tips on a Boston Fern almost always mean **dry air** rather than dry soil. Bathrooms are usually humid, but if yours has an extractor fan or gets a lot of airflow, the humidity drops fast after a shower and the fronds dry out at the edges first.\n\n**This week, move Fernie onto a tray of pebbles with water in it**, keeping the pot above the waterline. The water evaporating around the plant raises the humidity right where it matters. Don't trim the brown tips yet — wait and see whether the new growth comes in clean."
)

fernie_chat.messages.create!(
  role: "user",
  content: "Should I be misting it as well?"
)

fernie_chat.messages.create!(
  role: "assistant",
  content: "Misting feels productive but the effect only lasts a few minutes, so it won't fix the underlying dryness. The pebble tray is doing the real work here.\n\nIf you want to do something extra, **check the soil is staying evenly damp** rather than drying out between waterings. Ferns don't like to dry out fully. You're on the right track — the fact you spotted this early means Fernie should recover fine."
)

puts "Seeded #{User.count} users, #{Plant.count} plants and #{Chat.count} chat with #{Message.count} messages!"
