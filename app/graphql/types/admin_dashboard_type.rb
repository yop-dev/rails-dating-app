# app/graphql/types/admin_dashboard_type.rb
module Types
  class AdminDashboardType < Types::BaseObject
    field :total_users, Integer, null: false
    field :total_matches, Integer, null: false
    field :total_messages, Integer, null: false
    field :users_today, Integer, null: false
    field :matches_today, Integer, null: false
    field :messages_today, Integer, null: false
    field :users_this_week, Integer, null: false
    field :matches_this_week, Integer, null: false
    field :messages_this_week, Integer, null: false
    field :average_matches_per_user, Float, null: false
    field :average_messages_per_match, Float, null: false

    def average_matches_per_user
      return 0.0 if object.total_users == 0
      (object.total_matches.to_f / object.total_users).round(2)
    end

    def average_messages_per_match
      return 0.0 if object.total_matches == 0
      (object.total_messages.to_f / object.total_matches).round(2)
    end
  end
end