require 'rails_helper'

describe EventUser, type: :model do
  let(:event) { create(:event, creator: user) }
  let(:user) { create(:user) }
  subject(:event_user) { event.event_users.create(user: user) }

  describe '#update_rsvp' do
    it 'creates times from a hash of dates' do

    end
  end
end
