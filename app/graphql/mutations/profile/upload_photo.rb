# app/graphql/mutations/profile/upload_photo.rb
module Mutations
  module Profile
    class UploadPhoto < Mutations::BaseMutation
      # We assume you're storing a URL; if using ActiveStorage use Upload scalar & attach
      argument :url, String, required: true
      field :photo, Types::PhotoType, null: true

      def resolve(url:)
        user = require_current_user!
        if user.photos.count >= 5
          raise GraphQL::ExecutionError, "Max 5 photos allowed"
        end
        photo = user.photos.create!(url: url, position: user.photos.count)
        { photo: photo }
      end
    end
  end
end
