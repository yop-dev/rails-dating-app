# app/models/conversation.rb
class Conversation < ApplicationRecord
  has_many :messages, dependent: :destroy

  # associations for GraphQL
  belongs_to :user_a, class_name: "User", foreign_key: :user_a_id
  belongs_to :user_b, class_name: "User", foreign_key: :user_b_id

  # canonicalize by sorted user ids
  def self.between(u1, u2)
    a, b = [u1.id, u2.id].sort
    find_or_create_by(user_a_id: a, user_b_id: b)
  end

  # convenience methods
  def users
    [user_a, user_b]
  end

  def includes_user?(user)
    [user_a_id, user_b_id].include?(user.id)
  end

  def last_message
    messages.order(created_at: :desc).first
  end
end
