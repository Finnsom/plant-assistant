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

    title = first_user_message.content.presence || "Plant photo diagnosis"
    update(title: title.truncate(40))
  end
end
