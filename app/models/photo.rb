# app/graphql/models/photo.rb
class Photo < ApplicationRecord
  belongs_to :user
  validates :url, presence: true
  validates :position, numericality: { only_integer: true }, allow_nil: true
  validates :is_primary, inclusion: { in: [true, false] }

  def url
    read_attribute(:url)
  end
end
