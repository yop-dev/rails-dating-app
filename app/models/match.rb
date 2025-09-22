# app/models/match.rb
class Match < ApplicationRecord
  belongs_to :user_one, class_name: 'User'
  belongs_to :user_two, class_name: 'User'

  validates :user_one_id, uniqueness: { scope: :user_two_id }

  # convenience
  def other_user(current_user)
    user_one_id == current_user.id ? user_two : user_one
  end

  def conversation
    # create or return conversation canonicalized by user IDs
    a, b = [user_one_id, user_two_id].sort
    Conversation.find_or_create_by(user_a_id: a, user_b_id: b)
  end
end
