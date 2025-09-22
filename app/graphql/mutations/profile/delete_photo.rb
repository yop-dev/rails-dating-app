# app/graphql/mutations/profile/delete_photo.rb
module Mutations
  module Profile
    class DeletePhoto < Mutations::BaseMutation
      argument :photo_id, ID, required: true
      field :success, Boolean, null: false

      def resolve(photo_id:)
        user = require_current_user!
        photo = user.photos.find(photo_id)
        photo.destroy!
        # optionally re-index positions
        user.photos.order(:position).each_with_index { |p, idx| p.update_column(:position, idx) }
        { success: true }
      end
    end
  end
end
