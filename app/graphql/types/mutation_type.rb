# app/graphql/types/mutation_type.rb
module Types
  class MutationType < Types::BaseObject
    # auth
    field :registerUser, mutation: Mutations::Auth::RegisterUser
    field :loginUser, mutation: Mutations::Auth::LoginUser

    # profile
    field :updateProfile, mutation: Mutations::Profile::UpdateProfile
    field :uploadPhoto, mutation: Mutations::Profile::UploadPhoto
    field :deletePhoto, mutation: Mutations::Profile::DeletePhoto
    field :setPrimaryPhoto, mutation: Mutations::Profile::SetPrimaryPhoto

    # swipe / like
    field :likeUser, mutation: Mutations::Swipe::LikeUser
    field :dislikeUser, mutation: Mutations::Swipe::DislikeUser

    # matches
    field :unmatchUser, mutation: Mutations::Match::UnmatchUser

    # messages
    field :sendMessage, mutation: Mutations::Message::SendMessage

    # admin (guarded inside mutations)
    field :adminCreateUser, mutation: Mutations::Admin::AdminCreateUser
    field :adminUpdateUser, mutation: Mutations::Admin::AdminUpdateUser
    field :adminDeleteUser, mutation: Mutations::Admin::AdminDeleteUser
    field :adminDeleteMatch, mutation: Mutations::Admin::AdminDeleteMatch
  end
end
