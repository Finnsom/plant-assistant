require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "message-controller@example.com", password: "password")
    @plant = @user.plants.create!(nickname: "Fern", species: "Boston fern")
    @chat = @user.chats.create!(plant: @plant, title: "Untitled")
    sign_in @user
  end

  test "chat form accepts an optional image" do
    get chat_url(@chat)

    assert_response :success
    assert_select "input[type=file][name='message[image]'][accept*='image/jpeg']", count: 1
    assert_select "textarea[name='message[content]'][required]", count: 0
  end

  test "sends an uploaded image to the AI and saves it with the message" do
    fake_chat = fake_ai_chat
    upload = fixture_file_upload(Rails.root.join("app/assets/images/logo.png"), "image/png")

    with_fake_ai_chat(fake_chat) do
      post chat_messages_url(@chat), params: { message: { content: "", image: upload } }
    end

    assert_redirected_to chat_path(@chat)
    user_message = @chat.messages.find_by!(role: "user")
    assert_predicate user_message.image, :attached?
    assert_equal "Please diagnose the problem visible in this plant photo.", fake_chat.prompt
    assert fake_chat.received_existing_image
    assert_equal "Plant photo diagnosis", @chat.reload.title
  end

  private

  def with_fake_ai_chat(fake_chat)
    original_chat_method = RubyLLM.method(:chat)
    RubyLLM.define_singleton_method(:chat) { fake_chat }
    yield
  ensure
    RubyLLM.define_singleton_method(:chat, original_chat_method)
  end

  def fake_ai_chat
    Struct.new(:prompt, :received_existing_image) do
      def add_message(*) = self
      def with_instructions(*) = self

      def ask(prompt, with: {})
        self.prompt = prompt
        self.received_existing_image = File.exist?(with[:image])
        Struct.new(:content).new("The plant needs help.")
      end
    end.new
  end
end
