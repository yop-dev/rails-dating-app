# app/graphql/mutations/admin/admin_create_user.rb
module Mutations
  module Admin
    class AdminCreateUser < BaseMutation
      # required fields according to your schema
      argument :first_name, String, required: true
      argument :last_name, String, required: true
      argument :mobile_number, String, required: true
      argument :email, String, required: true
      argument :password, String, required: true
      argument :birthdate, GraphQL::Types::ISO8601Date, required: true
      argument :gender, String, required: true
      argument :sexual_orientation, String, required: true
      argument :gender_interest, String, required: true
      argument :bio, String, required: true
      argument :country, String, required: false
      argument :state, String, required: false
      argument :city, String, required: false
      argument :school, String, required: false
      argument :role, String, required: false, default_value: "user"

      field :user, Types::UserType, null: true
      field :errors, [String], null: false

      def resolve(**args)
        admin = require_admin!  # raises if not admin
        user = User.new(args)
        if user.save
          { user: user, errors: [] }
        else
          { user: nil, errors: user.errors.full_messages }
        end
      end
    end
  end
end
