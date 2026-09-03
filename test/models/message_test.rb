require "test_helper"

class MessageTest < ActiveSupport::TestCase
  setup do
    user = User.create!(email: "message-model@example.com", password: "password")
    plant = user.plants.create!(nickname: "Fern", species: "Boston fern")
    @chat = user.chats.create!(plant: plant, title: "Untitled")
  end

  test "allows a user message containing only an image" do
    message = @chat.messages.build(role: "user")
    message.image.attach(
      io: File.open(Rails.root.join("app/assets/images/logo.png")),
      filename: "fern.png",
      content_type: "image/png"
    )

    assert_predicate message, :valid?
  end

  test "requires text or an image" do
    message = @chat.messages.build(role: "user")

    assert_not message.valid?
    assert_includes message.errors[:content], "can't be blank"
  end
end
