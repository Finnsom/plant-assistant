class Message < ApplicationRecord
  MAX_USER_MESSAGES = 10
  IMAGE_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_IMAGE_SIZE = 10.megabytes

  belongs_to :chat
  has_one_attached :image

  validates :role, presence: true
  validates :content, presence: true, if: -> { role == "user" && !image.attached? }
  validate :user_message_limit, if: -> { role == "user" }
  validate :acceptable_image

  after_create_commit :broadcast_append_to_chat

  private

  def broadcast_append_to_chat
    broadcast_append_to chat, target: "messages", partial: "messages/message", locals: { message: self }
  end

  def user_message_limit
    return unless chat.messages.where(role: "user").count >= MAX_USER_MESSAGES

    errors.add(:content, "You can only send #{MAX_USER_MESSAGES} messages per chat.")
  end

  def acceptable_image
    return unless image.attached?

    errors.add(:image, "must be a JPEG, PNG, or WebP image") unless IMAGE_CONTENT_TYPES.include?(image.content_type)
    errors.add(:image, "must be smaller than 10 MB") if image.byte_size > MAX_IMAGE_SIZE
  end
end
