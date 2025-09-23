# app/graphql/mutations/match/unmatch_user.rb
module Mutations
  module Match
    class UnmatchUser < Mutations::BaseMutation
      argument :targetUserId, ID, required: true
      field :success, Boolean, null: false

      def resolve(targetUserId:)
        user = require_current_user!
        target_user = User.find(targetUserId)
        
        # Find the match between the two users
        u1, u2 = [user.id, target_user.id].sort
        match = ::Match.find_by(user_one_id: u1, user_two_id: u2)
        
        unless match
          raise GraphQL::ExecutionError, "No match found between users"
        end
        
        match.destroy!
        { success: true }
      end
    end
  end
end
