require 'rails_helper'

describe OauthsController, type: :controller do
  before do
    session.clear
  end

  def set_controller_provider_variables
    controller.instance_variable_set(:"@provider", provider)
    controller.instance_variable_set(:"@user_hash", { uid: 1, user_info: { "email" => 'test@example.com', "name" => 'Mr Test' } } )
  end

  describe '#oauth' do
    context 'facebook' do
      before do
        get :oauth, provider: 'facebook'
      end

      it 'redirects to Facebook oauth' do
        callback_url = CGI.escape(auth_callback_url(provider: 'facebook'))
        client_id = ENV["FB_KEY"]
        expect(response).to redirect_to "https://www.facebook.com/dialog/oauth?client_id=#{client_id}&display=page&redirect_uri=#{callback_url}&response_type=code&scope=email&state="
      end

      it 'does not set return_to_url' do
        expect(session).to be_blank
      end
    end

    context 'with redirect_after_login' do
      before do
        get :oauth, provider: 'facebook', redirect_after_login: "/some_path"
      end

      it 'sets return_to_url' do
        expect(session[:return_to_url]).to eq "/some_path"
      end
    end
  end

  describe '#callback' do
    let(:user) { User.new }
    let(:provider) { double(:provider) }
    let(:user_mapping) { { email: "email", name: "name" } }

    context 'with existing not-oauthd user' do
      let!(:user) { create(:user, email: 'test@example.com') }

      before do
        allow(provider).to receive(:user_info_mapping).and_return(user_mapping)
        allow(controller).to receive(:login_from) do
          set_controller_provider_variables
          nil
        end
      end

      context 'without redirect in session' do
        before do
          get :callback, provider: 'facebook'
        end

        it 'adds the provider' do
          expect(user.reload.authentications.count).to eq 1
        end

        it 'logs in' do
          expect(session[:user_id]).to eq user.id.to_s
        end

        it { is_expected.to redirect_to root_path }
      end

      context 'with redirect in session' do
        before do
          session[:return_to_url] = "/some_path"
          get :callback, provider: 'facebook'
        end

        it { is_expected.to redirect_to "/some_path" }
      end
    end

    context 'with existing oauthd user' do
      before do
        allow(provider).to receive(:user_info_mapping).and_return(user_mapping)
        allow(controller).to receive(:login_from) do
          set_controller_provider_variables
          user
        end
      end

      context 'without redirect in session' do
        before do
          get :callback, provider: 'facebook'
        end

        it 'logs in from the provider' do
          expect(controller).to have_received(:login_from)
        end

        it 'assigns values to the user' do
          expect(user.name).to eq "Mr Test"
          expect(user.email).to eq "test@example.com"
        end

        it { is_expected.to redirect_to root_path }
      end

      context 'with redirect in session' do
        before do
          session[:return_to_url] = "/some_path"
          get :callback, provider: 'facebook'
        end

        it { is_expected.to redirect_to "/some_path" }
      end
    end

    context 'with new user' do
      before do
        allow(provider).to receive(:user_info_mapping).and_return(user_mapping)
        allow(controller).to receive(:login_from) do
          set_controller_provider_variables
          nil
        end

        # Pretend that Facebook is happy with this
        stub_request(:post, "https://graph.facebook.com/oauth/access_token").to_return(:status => 200, :body => "", :headers => {})
      end

      context 'with success' do
        it 'creates a new user' do
          expect(controller).to receive(:create_from).and_call_original
          get :callback, provider: 'facebook'
        end

        it 'redirects' do
          get :callback, provider: 'facebook'
          expect(response).to redirect_to root_path
        end
      end

      context 'with an unexpected failure' do
        before do
          allow(controller).to receive(:create_from).and_raise
          get :callback, provider: 'facebook'
        end

        it { is_expected.to set_flash[:alert] }
      end
    end

  end
end
