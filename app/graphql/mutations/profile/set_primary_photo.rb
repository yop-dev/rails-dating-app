# app/graphql/mutations/profile/set_primary_photo.rb
module Mutations
  module Profile
    class SetPrimaryPhoto < BaseMutation
      argument :photo_id, ID, required: true

      field :photo, Types::PhotoType, null: true
      field :success, Boolean, null: false
      field :errors, [String], null: false

      def resolve(photo_id:)
        user = require_current_user!
        photo = user.photos.find_by(id: photo_id)
        
        unless photo
          return { photo: nil, success: false, errors: ["Photo not found"] }
        end

        # Set all photos to not primary
        user.photos.update_all(is_primary: false)
        
        # Set the specified photo as primary
        if photo.update(is_primary: true)
          { photo: photo, success: true, errors: [] }
        else
          { photo: nil, success: false, errors: photo.errors.full_messages }
        end
      end
    end
  end
end