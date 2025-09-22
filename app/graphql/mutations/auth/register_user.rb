# app/graphql/mutations/auth/register_user.rb
module Mutations
  module Auth
    class RegisterUser < Mutations::BaseMutation
      argument :first_name, String, required: true
      argument :last_name, String, required: true
      argument :email, String, required: true
      argument :mobile_number, String, required: true
      argument :password, String, required: true
      argument :birthdate, GraphQL::Types::ISO8601Date, required: true
      argument :gender, String, required: true
      argument :sexual_orientation, String, required: true
      argument :gender_interest, String, required: true
      argument :bio, String, required: true

      field :user, Types::UserType, null: true

      def resolve(**args)
        user = User.new(args)
        user.save!
        { user: user }
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError.new("Invalid input: #{e.record.errors.full_messages.join(', ')}")
      end
    end
  end
end
