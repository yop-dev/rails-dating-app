# app/graphql/mutations/profile/update_profile.rb
module Mutations
  module Profile
    class UpdateProfile < BaseMutation
      argument :first_name, String, required: false
      argument :last_name, String, required: false
      argument :gender_interest, String, required: false
      argument :bio, String, required: false
      argument :school, String, required: false

      field :user, Types::UserType, null: true

      def resolve(**args)
        user = context[:current_user]
        user.update!(args)
        { user: }
      end
    end
  end
end
