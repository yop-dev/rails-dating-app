# app/graphql/types/match_type.rb
module Types
  class MatchType < Types::BaseObject
    field :id, ID, null: false
    field :user_one, Types::UserType, null: false
    field :user_two, Types::UserType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
