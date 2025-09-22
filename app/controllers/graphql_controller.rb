# app/controllers/graphql_controller.rb
class GraphqlController < ApplicationController
  # remove protect_from_forgery
  # protect_from_forgery with: :null_session  # ❌ remove

  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    # ✅ Set context with current_user
    context = {
      current_user: current_user_from_token
    }

    result = TinderCloneSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )
    render json: result
  rescue => e
    render json: { errors: [{ message: e.message }] }, status: 500
  end

  private

  def current_user_from_token
    auth_header = request.headers['Authorization']
    return nil if auth_header.blank?

    token = auth_header.split(' ').last
    return nil if token.blank?

    payload = JsonWebToken.decode(token) rescue nil
    return nil unless payload && payload['user_id']

    User.find_by(id: payload['user_id'])
  rescue
    nil
  end

  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      ambiguous_param.present? ? JSON.parse(ambiguous_param) : {}
    when Hash
      ambiguous_param
    when ActionController::Parameters
      ambiguous_param.to_unsafe_hash
    else
      {}
    end
  end
end
