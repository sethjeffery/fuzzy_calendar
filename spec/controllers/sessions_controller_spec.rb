require 'rails_helper'

describe SessionsController, type: :controller do
  describe '#destroy' do
    before do
      session[:user_id] = 1
      get :destroy
    end

    it 'clears the session' do
      expect(session).to_not be_present
    end

    it { is_expected.to redirect_to root_path }
  end

  describe '#create' do
    let(:user) { build(:user) }

    before do
      allow(controller).to receive(:login).with("name", "password", true).and_return(user)
      allow(controller).to receive(:login).with("wrong", "wrong", true).and_return(nil)
    end

    context 'with correct credentials' do
      context 'with redirection url' do
        before do
          post :create, session: { email: 'name', password: 'password' }, redirect_after_login: '/somewhere'
        end

        it 'logs in the user' do
          expect(controller).to have_received(:login).with("name", "password", true)
        end

        it 'redirects to the return_to_url param' do
          expect(response).to redirect_to '/somewhere'
        end
      end

      context 'with redirection session' do
        before do
          session[:return_to_url] = "/somewhere_else"
          post :create, session: { email: 'name', password: 'password' }, redirect_after_login: ''
        end

        it 'logs in the user' do
          expect(controller).to have_received(:login).with("name", "password", true)
        end

        it 'redirects to the session variable' do
          expect(response).to redirect_to '/somewhere_else'
        end
      end
    end

    context 'with bad credentials' do
      before do
        post :create, session: { email: 'wrong', password: 'wrong' }
      end

      it { is_expected.to set_flash.now[:alert] }
      it { is_expected.to render_template :new }
    end
  end

  describe '#new' do
    it 'renders the new view' do
      get :new
      expect(response).to render_template :new
    end
  end
end
