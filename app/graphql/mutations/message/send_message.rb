module Mutations
  module Message
    class SendMessage < Mutations::BaseMutation
      argument :match_id, ID, required: true
      argument :content, String, required: true

      field :message, Types::MessageType, null: true

      def resolve(match_id:, content:)
        sender = require_current_user!
        match = ::Match.find(match_id)  # ✅ top-level constant

        # ensure sender is part of match
        unless [match.user_one_id, match.user_two_id].include?(sender.id)
          raise GraphQL::ExecutionError, "Not a participant in the match"
        end

        # get or create conversation for this match (assumes Match#conversation helper exists)
        conv = match.conversation
        message = conv.messages.create!(sender: sender, content: content, read: false)
        { message: message }
      end
    end
  end
end
