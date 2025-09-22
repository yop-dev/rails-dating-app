# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: 'User'

  validates :content, presence: true
  validates :conversation, presence: true
  validates :sender, presence: true
end
