# app/graphql/types/mutation_type.rb
module Types
  class MutationType < Types::BaseObject
    # auth
    field :register_user, mutation: Mutations::Auth::RegisterUser
    field :login_user, mutation: Mutations::Auth::LoginUser

    # profile
    field :update_profile, mutation: Mutations::Profile::UpdateProfile
    field :upload_photo, mutation: Mutations::Profile::UploadPhoto
    field :delete_photo, mutation: Mutations::Profile::DeletePhoto
    field :set_primary_photo, mutation: Mutations::Profile::SetPrimaryPhoto

    # swipe / like
    field :like_user, mutation: Mutations::Swipe::LikeUser
    field :dislike_user, mutation: Mutations::Swipe::DislikeUser

    # matches
    field :unmatch_user, mutation: Mutations::Match::UnmatchUser

    # messages
    field :send_message, mutation: Mutations::Message::SendMessage

    # admin (guarded inside mutations)
    field :admin_create_user, mutation: Mutations::Admin::AdminCreateUser
    field :admin_update_user, mutation: Mutations::Admin::AdminUpdateUser
    field :admin_delete_user, mutation: Mutations::Admin::AdminDeleteUser
    field :admin_delete_match, mutation: Mutations::Admin::AdminDeleteMatch
  end
end
