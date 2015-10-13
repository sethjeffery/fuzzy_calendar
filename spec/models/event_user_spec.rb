require 'rails_helper'

describe EventUser, type: :model do
  let(:event) { create(:event, creator: user) }
  let(:user) { create(:user) }
  subject(:event_user) { event.event_users.create(user: user) }

  describe '#update_rsvp' do
    context 'creator rsvping' do
      before do
        event_user.update_rsvp({ "2001-01-01" => {}, "2001-01-02" => { "favorite" => true } })
      end

      it 'creates times from a hash of dates' do
        expect(event_user.times.count).to eq 2
        expect(event_user.times.map(&:favorite)).to eq([false, true])
      end

      it 'does not send out mail' do
        expect(ActionMailer::Base.deliveries).to be_blank
      end
    end

    context 'non-creator rsvping' do
      let(:event) { create(:event) }

      before do
        event_user.update_rsvp({ "2001-01-01" => {}, "2001-01-02" => { "favorite" => true } })
      end

      it 'creates times from a hash of dates' do
        expect(event_user.times.count).to eq 2
        expect(event_user.times.map(&:favorite)).to eq([false, true])
      end

      it 'mails the event creator' do
        expect(ActionMailer::Base.deliveries).to be_present
        expect(ActionMailer::Base.deliveries.first.to).to eq([event.creator.email])
      end
    end

    context 'creator has no email' do
      let(:event) { create(:event, creator: create(:user, email: nil, authenticated_with_provider: true)) }

      before do
        event_user.update_rsvp({ "2001-01-01" => {}, "2001-01-02" => { "favorite" => true } })
      end

      it 'does not send out mail' do
        expect(ActionMailer::Base.deliveries).to be_blank
      end
    end
  end
end
