# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  # photos: assumed fields [:url, :position, :is_primary]
  has_many :photos, -> { order(position: :asc) }, dependent: :destroy

  has_many :likes_given, class_name: 'Like', foreign_key: :liker_id, dependent: :destroy
  has_many :likes_received, class_name: 'Like', foreign_key: :liked_id, dependent: :destroy

  has_many :matches_as_user_one, class_name: 'Match', foreign_key: :user_one_id, dependent: :destroy
  has_many :matches_as_user_two, class_name: 'Match', foreign_key: :user_two_id, dependent: :destroy

  has_many :conversations_as_a, class_name: 'Conversation', foreign_key: :user_a_id
  has_many :conversations_as_b, class_name: 'Conversation', foreign_key: :user_b_id

  validates :first_name, :last_name, :email, :mobile_number, :birthdate, :gender, :gender_interest, presence: true
  validates :email, uniqueness: true

  # convenience methods
  def primary_photo
    photos.find_by(is_primary: true) || photos.first
  end

  def age
    return nil unless birthdate
    now = Date.current
    now.year - birthdate.year - ((now.month > birthdate.month || (now.month == birthdate.month && now.day >= birthdate.day)) ? 0 : 1)
  end

  def matches
    user_ids = matches_as_user_one.pluck(:user_two_id) + matches_as_user_two.pluck(:user_one_id)
    User.where(id: user_ids)
  end

  def conversations
    Conversation.where(user_a_id: id).or(Conversation.where(user_b_id: id))
  end

  def matched_with?(other_user)
    u1, u2 = [id, other_user.id].sort
    Match.exists?(user_one_id: u1, user_two_id: u2)
  end

  def admin?
    self.role.to_s.downcase == "superadmin" || self.role.to_s.downcase == "admin"
  end
end
