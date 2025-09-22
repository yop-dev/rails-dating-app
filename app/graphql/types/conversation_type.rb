module Types
  class ConversationType < Types::BaseObject
    field :id, ID, null: false

    # camelCase fields for GraphQL
    field :userA, Types::UserType, null: false, method: :user_a
    field :userB, Types::UserType, null: false, method: :user_b
    field :messages, [Types::MessageType], null: true
    field :lastMessage, Types::MessageType, null: true, method: :last_message

    # you can remove this method; method: :last_message handles it
    # def last_message
    #   object.messages.order(created_at: :desc).first
    # end
  end
end
