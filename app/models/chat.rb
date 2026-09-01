class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :plant
  has_many :messages, dependent: :destroy
end
