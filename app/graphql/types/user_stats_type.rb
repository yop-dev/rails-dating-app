# app/graphql/types/user_stats_type.rb
module Types
  class UserStatsType < Types::BaseObject
    field :id, ID, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :email, String, null: false
    field :primary_photo_url, String, null: true
    field :match_count, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :gender, String, null: false
    field :age, Integer, null: true
    field :city, String, null: true
    field :state, String, null: true
    field :country, String, null: true

    def primary_photo_url
      # For OpenStruct objects from our query, find the user and get primary photo
      if object.respond_to?(:id)
        user = User.find_by(id: object.id)
        user&.primary_photo&.url
      else
        object.primary_photo&.url
      end
    end

    def age
      # Calculate age from birthdate if available
      if object.respond_to?(:birthdate) && object.birthdate
        birthdate = object.birthdate.is_a?(String) ? Date.parse(object.birthdate) : object.birthdate
        now = Date.current
        now.year - birthdate.year - ((now.month > birthdate.month || (now.month == birthdate.month && now.day >= birthdate.day)) ? 0 : 1)
      else
        nil
      end
    end

    def match_count
      # This will be set directly in our query result
      object.respond_to?(:match_count) ? object.match_count : 0
    end
  end
end