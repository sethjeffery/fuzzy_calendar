class OauthsController < ApplicationController
  skip_before_filter :require_login
  skip_after_filter :save_last_request

  # sends the user on a trip to the provider,
  # and after authorizing there back to the callback url.
  def oauth
    session[:return_to_url] = params[:redirect_after_login]
    login_at(auth_params[:provider])
  end

  def callback
    provider = auth_params[:provider]
    @user = login_from(provider)

    if @user
      attrs = user_attrs(@provider.user_info_mapping, @user_hash)
      @user.update_attributes(attrs)

      redirect_back_or_to events_path
    else
      #begin
        @user = create_from(provider) {|user|
          user.password = SecureRandom.hex
        }

        # NOTE: this is the place to add '@user.activate!' if you are using user_activation submodule

        reset_session # protect from session fixation attack
        auto_login(@user)
        redirect_back_or_to events_path
      #rescue
      #  raise "Failed"
      #  redirect_to events_path, :alert => "Failed to login from #{provider.titleize}!"
      #end
    end
  end

  #example for Rails 4: add private method below and use "auth_params[:provider]" in place of 
  #"params[:provider] above.

  private
  def auth_params
    params.permit(:code, :provider)
  end

end
