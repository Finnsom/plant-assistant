class Plant < ApplicationRecord
  IMAGE_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_IMAGE_SIZE = 10.megabytes

  belongs_to :user
  has_many :chats, dependent: :destroy
  has_one_attached :photo

  validates :nickname, presence: true
  validates :species, presence: true
  validate :acceptable_photo

  def care_profile
    PlantCareCatalog.find(species)
  end

  private

  def acceptable_photo
    return unless photo.attached?

    errors.add(:photo, "must be a JPEG, PNG, or WebP image") unless IMAGE_CONTENT_TYPES.include?(photo.content_type)
    errors.add(:photo, "must be smaller than 10 MB") if photo.byte_size > MAX_IMAGE_SIZE
  end
end
