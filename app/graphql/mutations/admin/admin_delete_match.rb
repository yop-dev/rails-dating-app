module Mutations
  module Admin
    class AdminDeleteMatch < BaseMutation
      argument :id, ID, required: true

      field :success, Boolean, null: false
      field :errors, [String], null: false

      def resolve(id:)
        match = Match.find_by(id: id)
        return { success: false, errors: ["Match not found"] } unless match

        if match.destroy
          { success: true, errors: [] }
        else
          { success: false, errors: match.errors.full_messages }
        end
      end
    end
  end
end
