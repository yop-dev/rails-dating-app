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
      argument :country, String, required: false
      argument :state, String, required: false
      argument :city, String, required: false
      argument :school, String, required: false

      # 🔥 allow file uploads
      argument :photos, [ApolloUploadServer::Upload], required: true

      field :user, Types::UserType, null: true

      def resolve(photos:, **args)
        if photos.size < 1 || photos.size > 5
          raise GraphQL::ExecutionError, "You must upload between 1 and 5 photos."
        end

        user = User.new(args)

        if user.save
          photos.each_with_index do |upload, idx|
            # Upload to Cloudinary
            result = Cloudinary::Uploader.upload(
              upload.to_io,
              public_id: upload.original_filename,
              folder: "user_photos/#{user.id}"
            )

            # Create Photo record
            user.photos.create!(
              url: result["secure_url"],
              position: idx + 1,
              is_primary: (idx == 0)
            )
          end

          { user: user }
        else
          raise GraphQL::ExecutionError, "Invalid input: #{user.errors.full_messages.join(', ')}"
        end
      end
    end
  end
end
