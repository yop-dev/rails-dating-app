module Mutations
  module Admin
    class AdminUpdateUser < BaseMutation
      argument :id, ID, required: true
      argument :first_name, String, required: false
      argument :last_name, String, required: false
      argument :email, String, required: false
      argument :mobile_number, String, required: false
      argument :birthdate, GraphQL::Types::ISO8601Date, required: false
      argument :gender, String, required: false
      argument :sexual_orientation, String, required: false
      argument :gender_interest, String, required: false
      argument :bio, String, required: false
      argument :country, String, required: false
      argument :state, String, required: false
      argument :city, String, required: false
      argument :school, String, required: false
      argument :role, String, required: false

      field :user, Types::UserType, null: true
      field :errors, [String], null: false

      def resolve(id:, **args)
        admin = require_admin!  # raises if not admin
        user = User.find_by(id: id)
        return { user: nil, errors: ["User not found"] } unless user

        # Remove nil values from args to avoid overwriting with nil
        update_args = args.compact
        
        if user.update(update_args)
          { user: user, errors: [] }
        else
          { user: nil, errors: user.errors.full_messages }
        end
      end
    end
  end
end
