module Mutations
  module Swipe
    class DislikeUser < BaseMutation
      argument :targetUserId, ID, required: true

      field :success, Boolean, null: false

      def resolve(targetUserId:)
        user = require_current_user!
        target_user = User.find(targetUserId)

        # Find or build a Like record
        like = Like.find_or_initialize_by(liker: user, liked_id: target_user.id)
        like.is_like = false
        like.save!

        # Remove any existing match
        u1, u2 = [user.id, target_user.id].sort
        match = ::Match.find_by(user_one_id: u1, user_two_id: u2)
        match&.destroy

        { success: true }
      rescue ActiveRecord::RecordNotFound
        raise GraphQL::ExecutionError, "Target user not found"
      end
    end
  end
end
