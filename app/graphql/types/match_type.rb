# app/graphql/types/match_type.rb
module Types
  class MatchType < Types::BaseObject
    field :id, ID, null: false
  field :userOne, Types::UserType, null: false
  field :userTwo, Types::UserType, null: false
  field :createdAt, GraphQL::Types::ISO8601DateTime, null: false
  field :updatedAt, GraphQL::Types::ISO8601DateTime, null: false

  # Map camelCase field names to snake_case attribute names
  def userOne
    object.user_one
  end

  def userTwo
    object.user_two
  end

  def createdAt
    object.created_at
  end

  def updatedAt
    object.updated_at
  end
  end
end
