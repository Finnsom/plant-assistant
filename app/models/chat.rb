class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :plant

  has_many :messages, dependent: :destroy

  def display_title
    return "New chat about #{plant.nickname}" if title == "Untitled"

    title
  end

  def generate_title_from_first_message
    return unless title == "Untitled"

    first_user_message = messages.where(role: "user").order(:created_at).first
    return if first_user_message.nil?

    update(title: first_user_message.content.truncate(40))
  end
end
