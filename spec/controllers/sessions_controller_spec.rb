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
end
