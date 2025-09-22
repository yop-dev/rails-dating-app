# app/graphql/mutations/auth/login_user.rb
module Mutations
  module Auth
    class LoginUser < Mutations::BaseMutation
      argument :email, String, required: true
      argument :password, String, required: true

      field :user, Types::UserType, null: true
      field :token, String, null: true

      def resolve(email:, password:)
        user = User.find_by(email: email)
        if user&.authenticate(password)
          token = JsonWebToken.encode(user_id: user.id) rescue nil
          { user: user, token: token }
        else
          raise GraphQL::ExecutionError, "Invalid credentials"
        end
      end
    end
  end
end
