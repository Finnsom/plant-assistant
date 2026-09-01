class Plant < ApplicationRecord
  belongs_to :user
  has_many :chats, dependent: :destroy
  validates :nickname, presence: true
  validates :species, presence: true
end
