# app/graphql/types/query_type.rb
module Types
  class QueryType < Types::BaseObject
    # current user
    field :currentUser, Types::UserType, null: true
    def current_user
      context[:current_user]
    end

    # get a user by id
    field :user, Types::UserType, null: true do
      argument :id, ID, required: true
    end
    def user(id:)
      User.find_by(id: id)
    end

    # potential swipes
    field :potentialUsers, [Types::UserType], null: true do
      argument :limit, Integer, required: false, default_value: 25
    end
    def potential_users(limit:)
      u = context[:current_user] or return []
      interest = u.gender_interest
      scope = User.where.not(id: u.id)
      scope = scope.where(gender: interest) unless interest.blank? || interest.downcase == "both"
      scope.limit(limit)
    end

    # matches (supports current user OR explicit userId)
    field :matches, [Types::MatchType], null: true do
      description "Return matches for the current user or for a given userId"
      argument :userId, ID, required: false
      argument :limit, Integer, required: false, default_value: 50
      argument :offset, Integer, required: false, default_value: 0
    end
    def matches(userId: nil, limit:, offset:)
      u = if userId
            User.find_by(id: userId)
          else
            context[:current_user]
          end
      return [] unless u

      Match.where("user_one_id = :uid OR user_two_id = :uid", uid: u.id)
          .order(created_at: :desc)
          .limit(limit)
          .offset(offset)
    end


    # conversations
    field :conversations, [Types::ConversationType], null: true
    def conversations
      u = context[:current_user] or return []
      Conversation.where(user_a_id: u.id).or(Conversation.where(user_b_id: u.id))
                  .order(updated_at: :desc)
    end

    # messages
    field :messages, [Types::MessageType], null: true do
      argument :conversationId, ID, required: true
    end
    def messages(conversationId:)
      conv = Conversation.find_by(id: conversationId)
      return [] unless conv
      conv.messages.order(created_at: :asc)
    end
  end
end
