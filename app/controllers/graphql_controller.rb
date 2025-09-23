# app/controllers/graphql_controller.rb
class GraphqlController < ApplicationController
  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

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

  def prepare_variables(variables_param)
    case variables_param
    when String
      variables_param.present? ? JSON.parse(variables_param) : {}
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_h
    else
      {}
    end
  end
end
