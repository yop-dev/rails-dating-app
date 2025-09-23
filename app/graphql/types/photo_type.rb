# app/graphql/types/photo_type.rb
module Types
  class PhotoType < Types::BaseObject
    field :id, ID, null: false
    field :url, String, null: true
    field :position, Integer, null: true
    field :isPrimary, Boolean, null: true

    def isPrimary
      object.is_primary
    end
  end
end
