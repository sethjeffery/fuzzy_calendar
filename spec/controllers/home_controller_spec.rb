require 'rails_helper'

describe HomeController, type: :controller do
  describe '#index' do
    context 'when logged_in' do
      before do
        expect(controller).to receive(:logged_in?).and_return(true)
        get :index
      end

      it 'renders dashboard page' do
        expect(response).to render_template :dashboard
      end
    end

    context 'when not logged_in' do
      before do
        expect(controller).to receive(:logged_in?).and_return(false)
        get :index
      end

      it 'renders welcome page' do
        expect(response).to render_template :welcome
      end
    end
  end
end
