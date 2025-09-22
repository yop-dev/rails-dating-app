# app/graphql/types/user_type.rb
module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :full_name, String, null: false
    field :email, String, null: false
    field :mobile_number, String, null: false
    field :birthdate, GraphQL::Types::ISO8601Date, null: false
    field :gender, String, null: false
    field :gender_interest, String, null: false
    field :bio, String, null: true
    field :country, String, null: true
    field :state, String, null: true
    field :city, String, null: true
    field :school, String, null: true
    field :age, Integer, null: true
    field :primary_photo_url, String, null: true
    field :photos, [Types::PhotoType], null: true

    field :role, String, null: false

    def full_name
      "#{object.first_name} #{object.last_name}"
    end

    def primary_photo_url
      object.primary_photo&.url
    end

    def age
      object.age
    end
  end
end
