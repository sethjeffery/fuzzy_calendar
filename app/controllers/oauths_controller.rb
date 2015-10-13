class OauthsController < ApplicationController
  skip_before_filter :require_login
  skip_after_filter :save_last_request

  # sends the user on a trip to the provider,
  # and after authorizing there back to the callback url.
  def oauth
    session[:return_to_url] = params[:redirect_after_login] if params[:redirect_after_login]
    login_at(auth_params[:provider])
  end

  def callback
    provider = auth_params[:provider]
    @user = login_from(provider)
    return_to_url = session[:return_to_url]

    attrs = user_attrs(@provider.user_info_mapping, @user_hash)

    if @user
      @user.update_attributes(attrs)
      redirect_to return_to_url || root_path

    else
      @user = User.find_by(email: attrs[:email])

      if @user
        reset_and_login @user
        @user.add_provider_to_user(provider, @user_hash[:uid].to_s)
        redirect_to return_to_url || root_path

      else
        begin
          @user = create_from(provider) {|user|
            user.password = SecureRandom.hex
            user.authenticated_with_provider = true
          }

          reset_and_login(@user)
          redirect_to return_to_url || root_path
        rescue
          redirect_to root_path, :alert => "Failed to login from #{provider.titleize}!"
        end
      end
    end
  end

  private

  def auth_params
    params.permit(:code, :provider)
  end

  def reset_and_login(user)
    reset_session # protect from session fixation attack
    auto_login(@user)
  end
end
