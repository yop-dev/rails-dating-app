class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, user: user.as_json(except: [:password_digest]) }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end
end
