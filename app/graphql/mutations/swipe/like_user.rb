module Mutations
  module Swipe
    class LikeUser < Mutations::BaseMutation
      argument :target_user_id, ID, required: true

      field :match, Types::MatchType, null: true
      field :match_created, Boolean, null: false

      def resolve(target_user_id:)
        user = require_current_user!
        target = User.find(target_user_id)

        # create or update like
        like = Like.find_or_initialize_by(liker: user, liked: target)
        like.is_like = true
        like.save!

        # check reciprocal
        if Like.exists?(liker: target, liked: user, is_like: true)
          # ensure unique ordering in Match (user_one_id < user_two_id)
          u1, u2 = [user.id, target.id].sort
          match = ::Match.find_or_create_by!(user_one_id: u1, user_two_id: u2)
          return { match: match, match_created: true }
        end

        { match: nil, match_created: false }
      end
    end
  end
end
