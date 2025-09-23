# app/graphql/types/user_type.rb
module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :firstName, String, null: false
    field :lastName, String, null: false
    field :fullName, String, null: false
    field :email, String, null: false
    field :mobileNumber, String, null: false
    field :birthdate, GraphQL::Types::ISO8601Date, null: false
    field :gender, String, null: false
    field :sexualOrientation, String, null: false
    field :genderInterest, String, null: false
    field :bio, String, null: true
    field :country, String, null: true
    field :state, String, null: true
    field :city, String, null: true
    field :school, String, null: true
    field :age, Integer, null: true
    field :primaryPhotoUrl, String, null: true
    field :photos, [Types::PhotoType], null: true

    field :role, String, null: false
    field :createdAt, GraphQL::Types::ISO8601DateTime, null: false
    field :updatedAt, GraphQL::Types::ISO8601DateTime, null: false

    def fullName
      "#{object.first_name} #{object.last_name}"
    end

    def primaryPhotoUrl
      object.primary_photo&.url
    end

    def age
      object.age
    end

    # Map camelCase field names to snake_case attribute names
    def firstName
      object.first_name
    end

    def lastName
      object.last_name
    end

    def mobileNumber
      object.mobile_number
    end

    def sexualOrientation
      object.sexual_orientation
    end

    def genderInterest
      object.gender_interest
    end

    def createdAt
      object.created_at
    end

    def updatedAt
      object.updated_at
    end
  end
end
