# app/graphql/mutations/match/unmatch_user.rb
module Mutations
  module Match
    class UnmatchUser < Mutations::BaseMutation
      argument :match_id, ID, required: true
      field :success, Boolean, null: false

      def resolve(match_id:)
        user = require_current_user!
        match = ::Match.find(match_id)
        # ensure user is part of match
        unless [match.user_one_id, match.user_two_id].include?(user.id)
          raise GraphQL::ExecutionError, "Not authorized to unmatch"
        end
        match.destroy!
        { success: true }
      end
    end
  end
end
