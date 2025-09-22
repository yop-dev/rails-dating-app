# app/graphql/mutations/base_mutation.rb
module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    null false

    # helper to return authorization error
    def require_current_user!
      return context[:current_user] if context[:current_user].present?
      raise GraphQL::ExecutionError, "Authentication required"
    end

    def require_admin!
      u = require_current_user!
      raise GraphQL::ExecutionError, "Unauthorized" unless u&.admin?
      u
    end
  end
end
