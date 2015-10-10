require 'rails_helper'

describe UsersController, type: :controller do
  let(:user) { build(:user) }

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

  describe '#edit' do
    it 'requires authentication' do
      get :edit
      expect(response).to redirect_to login_path
    end

    context 'logged in' do
      before do
        login_user(user)
      end

      it 'can only edit the current user' do
        get :edit, id: 187439482
        expect(assigns(:user)).to eq user
      end
    end
  end

  describe '#update' do
    it 'requires authentication' do
      put :update, id: 187439482
      expect(response).to redirect_to login_path
    end

    context 'logged in' do
      before do
        login_user(user)
      end

      it 'can only update the current user' do
        put :update, id: 187439482, user: { name: 'John' }
        expect(assigns(:user)).to eq user
      end

      context 'with invalid params' do
        before do
          put :update, id: 187439482, user: { name: '', password: '', email: '' }
        end

        it { is_expected.to render_template :edit }

        it 'returns a user with errors' do
          expect(assigns(:user).errors).to be_present
        end
      end

      context 'with valid params' do
        it 'updates name' do
          expect {
            put :update, id: 187439482, user: { name: 'New name' }
          }.to change{user.name}.to "New name"
        end

        it 'updates email' do
          expect {
            put :update, id: 187439482, user: { email: 'newemail@example.com' }
          }.to change{user.email}.to 'newemail@example.com'
        end

        it 'updates password' do
          expect {
            put :update, id: 187439482, user: { password: 'New password' }
          }.to change{user.crypted_password}
        end
      end
    end
  end
end
