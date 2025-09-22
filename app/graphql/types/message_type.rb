# app/graphql/types/message_type.rb
module Types
  class MessageType < Types::BaseObject
    field :id, ID, null: false
    field :conversation_id, ID, null: false
    field :sender, Types::UserType, null: false
    field :content, String, null: false
    field :read, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
