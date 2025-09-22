# app/models/like.rb
class Like < ApplicationRecord
  belongs_to :liker, class_name: 'User'
  belongs_to :liked, class_name: 'User'

  validates :liker_id, uniqueness: { scope: :liked_id }

  after_create :create_match_if_needed
  after_update :on_update
  after_destroy :destroy_match_if_exists

  private

  def create_match_if_needed
    return unless is_like
    reciprocal = Like.find_by(liker_id: liked_id, liked_id: liker_id, is_like: true)
    if reciprocal
      u1, u2 = [liker_id, liked_id].sort
      Match.find_or_create_by!(user_one_id: u1, user_two_id: u2)
    end
  end

  def on_update
    # if previously was like and changed to dislike, remove match
    if saved_change_to_is_like? && is_like == false
      u1, u2 = [liker_id, liked_id].sort
      m = Match.find_by(user_one_id: u1, user_two_id: u2)
      m&.destroy
    elsif saved_change_to_is_like? && is_like == true
      create_match_if_needed
    end
  end

  def destroy_match_if_exists
    # If like destroyed and reciprocal still exists, remove match
    reciprocal = Like.find_by(liker_id: liked_id, liked_id: liker_id, is_like: true)
    if reciprocal
      u1, u2 = [liker_id, liked_id].sort
      m = Match.find_by(user_one_id: u1, user_two_id: u2)
      m&.destroy
    end
  end
end
