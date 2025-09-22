module Mutations
  module Admin
    class AdminDeleteUser < BaseMutation
      argument :id, ID, required: true

      field :success, Boolean, null: false
      field :errors, [String], null: false

      def resolve(id:)
        user = User.find_by(id: id)
        return { success: false, errors: ["User not found"] } unless user

        if user.destroy
          { success: true, errors: [] }
        else
          { success: false, errors: user.errors.full_messages }
        end
      end
    end
  end
end
