require 'rails_helper'

describe EventsController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  before do
    allow(Event).to receive(:find).with(event.to_param).and_return(event)
  end

  describe '#new' do
    context 'not logged in' do
      before { get :new }
      it { is_expected.to redirect_to root_path }
    end

    context 'logged in' do
      before do
        login_user(user)
        get :new
      end

      it { is_expected.to render_template :new }

      it 'instantiates a new event' do
        expect(assigns(:event)).to be_an Event
      end
    end
  end

  describe '#create' do
    context 'not logged in' do
      before { post :create }
      it { is_expected.to redirect_to root_path }
    end

    context 'logged in' do
      before do
        login_user(user)
      end

      context 'with invalid params' do
        before do
          post :create, event: { name: '', date_range: "{}" }
        end

        it { is_expected.to render_template :new }

        it 'returns the invalid event' do
          expect(assigns(:event)).to be_present
        end
      end

      context 'with valid params' do
        it 'creates a new event' do
          expect {
            post :create, event: { name: "New event", specificity: "day", date_range: { "2015-01-15" => {} }.to_json }
          }.to change{Event.count}.by 1
        end

        it 'redirects to new event path' do
          post :create, event: { name: "New event", specificity: "day", date_range: { "2015-01-15" => {} }.to_json }
          event = Event.last
          expect(response).to redirect_to event_path(event)
        end
      end
    end
  end

  describe '#rsvp' do
    context 'not logged in' do
      before { post :rsvp, id: event.to_param, rsvp: {} }
      it { is_expected.to redirect_to login_path }
    end

    context 'logged in' do
      before do
        login_user(user)
      end

      context 'successful update' do
        let(:event_user) { EventUser.new }

        before do
          allow(event.event_users).to receive(:find_or_create_by).and_return(event_user)
          allow(event_user).to receive(:update_rsvp).and_return(true)
          post :rsvp, id: event.to_param, rsvp: { dates: "{}" }
        end

        it 'fetches event_user' do
          expect(event.event_users).to have_received(:find_or_create_by).with(user_id: user.id)
        end

        it 'performs update' do
          expect(event_user).to have_received(:update_rsvp)
        end

        it { is_expected.to redirect_to event_path(event) }
        it { is_expected.to_not set_flash }
      end

      context 'failure updating' do
        before do
          expect_any_instance_of(EventUser).to receive(:update_rsvp).and_return(false)
          post :rsvp, id: event.to_param, rsvp: { dates: "{}" }
        end

        it { is_expected.to redirect_to event_path(event) }
        it { is_expected.to set_flash[:alert] }
      end
    end
  end

  describe '#close' do
    context 'not logged in' do
      before { put :close, id: event.to_param }
      it { is_expected.to redirect_to login_path }
    end

    context 'not event creator' do
      it 'renders 404' do
        expect {
          login_user(user)
          put :close, id: event.to_param, event: {}
        }.to raise_error ActionController::RoutingError
      end
    end

    context 'logged in as creator' do
      before do
        login_user(user)
        event.creator = user
        put :close, id: event.to_param, event: {}
      end

      it 'closes the event' do
        expect(event.closed?).to be true
      end

      it { is_expected.to redirect_to event_path(event) }
    end
  end

  describe '#finalise' do
    context 'not logged in' do
      before { put :finalise, id: event.to_param }
      it { is_expected.to redirect_to login_path }
    end

    context 'not event creator' do
      it 'renders 404' do
        expect {
          login_user(user)
          put :finalise, id: event.to_param, event: {}
        }.to raise_error ActionController::RoutingError
      end
    end

    context 'logged in as creator' do
      before do
        login_user(user)
        event.creator = user
        put :finalise, id: event.to_param, event: { agreed_time: {"2001-01-01" => {}}.to_json }
      end

      it 'finalises the event' do
        expect(event.finalised?).to be true
      end

      it { is_expected.to redirect_to event_path(event) }
    end
  end
end
