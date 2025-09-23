# app/graphql/types/query_type.rb
require 'ostruct'

module Types
  class QueryType < Types::BaseObject
    # current user
    field :currentUser, Types::UserType, null: true
    def currentUser
      context[:current_user]
    end

    # get a user by id
    field :user, Types::UserType, null: true do
      argument :id, ID, required: true
    end
    def user(id:)
      User.find_by(id: id)
    end

    # potential swipes
    field :potentialUsers, [Types::UserType], null: true do
      argument :limit, Integer, required: false, default_value: 25
    end
    def potentialUsers(limit:)
      u = context[:current_user] or return []

      # Start with everyone except yourself
      scope = User.where.not(id: u.id)

      # Apply gender interest filter (skip if interest = "both")
      # NOTE: Matching is based on gender_interest only, NOT sexual_orientation
      # sexual_orientation is for profile display purposes only
      interest = u.gender_interest
      unless interest.blank? || interest.downcase == "both"
        # Handle case-insensitive gender matching
        scope = scope.where("LOWER(gender) = LOWER(?)", interest)
      end

      # Only exclude users the current user already LIKED (not disliked)
      # This allows users to see disliked users again in future sessions
      liked_user_ids = Like.where(liker_id: u.id, is_like: true).pluck(:liked_id)

      # Exclude users the current user is already matched with
      matched_user_ids = Match.where("user_one_id = :id OR user_two_id = :id", id: u.id)
                              .pluck(:user_one_id, :user_two_id)
                              .flatten
                              .uniq

      # Combine exclusions (only liked users and matched users)
      exclude_ids = liked_user_ids + matched_user_ids
      scope = scope.where.not(id: exclude_ids)

      # Limit results
      scope.limit(limit)
    end

    # matches (supports current user OR explicit userId)
    field :matches, [Types::MatchType], null: true do
      description "Return matches for the current user or for a given userId"
      argument :userId, ID, required: false
      argument :limit, Integer, required: false, default_value: 50
      argument :offset, Integer, required: false, default_value: 0
    end
    def matches(userId: nil, limit:, offset:)
      u = if userId
            User.find_by(id: userId)
          else
            context[:current_user]
          end
      return [] unless u

      Match.where("user_one_id = :uid OR user_two_id = :uid", uid: u.id)
          .order(created_at: :desc)
          .limit(limit)
          .offset(offset)
    end


    # conversations
    field :conversations, [Types::ConversationType], null: true
    def conversations
      u = context[:current_user] or return []
      Conversation.where(user_a_id: u.id).or(Conversation.where(user_b_id: u.id))
                  .order(updated_at: :desc)
    end

    # messages
    field :messages, [Types::MessageType], null: true do
      argument :conversationId, ID, required: true
    end
    def messages(conversationId:)
      conv = Conversation.find_by(id: conversationId)
      return [] unless conv
      conv.messages.order(created_at: :asc)
    end

    # ADMIN QUERIES
    
    # all users with match statistics (admin only)
    field :allUsersWithStats, [Types::UserStatsType], null: true do
      description "Get all users with their match statistics (admin only)"
      argument :limit, Integer, required: false, default_value: 50
      argument :offset, Integer, required: false, default_value: 0
      argument :orderBy, String, required: false, default_value: "created_at"
      argument :orderDirection, String, required: false, default_value: "DESC"
    end
    def allUsersWithStats(limit:, offset:, orderBy:, orderDirection:)
      # Require admin authentication
      current_user = context[:current_user]
      unless current_user&.admin?
        raise GraphQL::ExecutionError, "Unauthorized: Admin access required"
      end
      
      # Get all users first
      users = User.all
      
      # Calculate match counts for each user
      users_with_stats = users.map do |user|
        # Count matches where user is either user_one or user_two
        match_count = Match.where(
          "user_one_id = ? OR user_two_id = ?", user.id, user.id
        ).count
        
        # Create a hash with user attributes plus match_count
        user_attrs = user.attributes
        user_attrs['match_count'] = match_count
        
        # Convert to OpenStruct so it behaves like an ActiveRecord object
        OpenStruct.new(user_attrs)
      end
      
      # Apply ordering
      valid_orders = %w[created_at first_name last_name match_count email]
      order_field = valid_orders.include?(orderBy) ? orderBy : 'created_at'
      reverse = orderDirection.upcase == 'DESC'
      
      users_with_stats = users_with_stats.sort_by do |user_stat|
        value = user_stat.send(order_field)
        # Handle different data types for sorting
        case value
        when String
          value.downcase
        when nil
          reverse ? '' : 'zzz'  # nil values go to end
        else
          value
        end
      end
      
      users_with_stats.reverse! if reverse
      
      # Apply pagination
      users_with_stats[offset, limit] || []
    end

    # admin dashboard statistics
    field :adminDashboard, Types::AdminDashboardType, null: true do
      description "Get admin dashboard statistics (admin only)"
    end
    def adminDashboard
      # Require admin authentication
      current_user = context[:current_user]
      unless current_user&.admin?
        raise GraphQL::ExecutionError, "Unauthorized: Admin access required"
      end
      
      # Return an object that will be handled by AdminDashboardType
      OpenStruct.new(
        total_users: User.count,
        total_matches: Match.count,
        total_messages: Message.count,
        users_today: User.where('created_at >= ?', Date.current.beginning_of_day).count,
        matches_today: Match.where('created_at >= ?', Date.current.beginning_of_day).count,
        messages_today: Message.where('created_at >= ?', Date.current.beginning_of_day).count,
        users_this_week: User.where('created_at >= ?', 1.week.ago).count,
        matches_this_week: Match.where('created_at >= ?', 1.week.ago).count,
        messages_this_week: Message.where('created_at >= ?', 1.week.ago).count
      )
    end
  end
end
