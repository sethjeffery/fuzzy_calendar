require 'rails_helper'

describe UsersController, type: :controller do
  describe '#new' do
    it 'renders the new view' do
      get :new
      expect(response).to render_template :new
    end
  end

  describe '#create' do
    context 'with valid params' do
      context 'with redirection url' do
        before do
          post :create, user: { name: 'bob', email: 'email@example.com', password: 'password' }, redirect_after_login: '/somewhere'
        end

        it 'creates the user' do
          expect(User.last.name).to eq 'bob'
          expect(User.last.email).to eq 'email@example.com'
        end

        it 'logs in the user' do
          expect(session[:user_id]).to eq User.last.id.to_s
        end

        it 'redirects to the return_to_url param' do
          expect(response).to redirect_to '/somewhere'
        end
      end

      context 'with redirection session' do
        before do
          session[:return_to_url] = "/somewhere_else"
          post :create, user: { name: 'bob', email: 'email@example.com', password: 'password' }, redirect_after_login: ''
        end

        it 'creates the user' do
          expect(User.last.name).to eq 'bob'
          expect(User.last.email).to eq 'email@example.com'
        end

        it 'logs in the user' do
          expect(session[:user_id]).to eq User.last.id.to_s
        end

        it 'redirects to the session variable' do
          expect(response).to redirect_to '/somewhere_else'
        end
      end
    end

    context 'with invalid params' do
      before do
        post :create, user: { name: '', email: '' }
      end

      it { is_expected.to render_template :new }

      it 'provides a user with errors' do
        expect(assigns(:user).errors).to be_present
      end
    end
  end
end
