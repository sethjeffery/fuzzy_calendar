require 'rails_helper'

describe ContactsController, type: :controller do
  describe '#show' do
    before do
      get :show
    end

    it { is_expected.to render_template :show }
  end

  describe '#create' do
    context 'with invalid params' do
      before do
        post :create, contact: { name: '', email: "" }
      end

      it { is_expected.to render_template :show }

      it 'returns the invalid contact' do
        expect(assigns(:contact)).to be_present
      end
    end

    context 'with valid params and recaptcha' do
      before do
        allow(controller).to receive(:verify_recaptcha).and_return(true)
        post :create, contact: { name: 'John', email: "john@example.com", message: "Hi there" }
      end

      it 'sends an email' do
        expect(ActionMailer::Base.deliveries).to be_present
      end

      it { is_expected.to redirect_to thankyou_contact_path }
    end
  end

end
