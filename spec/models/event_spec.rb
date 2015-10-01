require 'rails_helper'

describe Event, type: :model do
  subject(:event) { build(:event) }

  it 'requires a name' do
    event.name = ""
    expect(event).to_not be_valid
  end

  it 'requires a start and end date' do
    event.starts_at = nil
    expect(event).to_not be_valid

    event.starts_at = Date.today
    event.ends_at = nil
    expect(event).to_not be_valid
  end

  describe '#state' do
    before do
      event.save
      recipient = create(:user)
      event.event_users.create user: recipient
    end

    it 'is open by default' do
      expect(event).to be_open
    end

    it 'can be closed' do
      event.close!
      expect(event).to be_closed
      expect(ActionMailer::Base.deliveries).to be_present
    end

    it 'can be finalised' do
      event.finalise!
      expect(event).to be_finalised
    end

    it 'can be finalised with a date hash' do
      event.finalise_with({ "2001-01-01" => {} })
      expect(event).to be_finalised
      expect(event.agreed_time).to eq DateTime.new(2001,1,1)
      expect(ActionMailer::Base.deliveries).to be_present
    end
  end

  describe '#date_range' do
    it 'reads first and last date' do
      event.date_range = { "2014-01-01" => {}, "2014-06-01" => {}, "2013-01-01" => {} }
      expect(event.starts_at).to eq DateTime.new(2013,1,1)
      expect(event.ends_at).to eq DateTime.new(2014,6,1)
    end
  end

  context 'with dates registered' do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }
    let(:user_c) { create(:user) }
    let(:event_user_a) { event.event_users.create(user: user_a) }
    let(:event_user_b) { event.event_users.create(user: user_b) }
    let(:event_user_c) { event.event_users.create(user: user_c) }

    before do
      event.save
      event_user_a.times.create(time: DateTime.new(2015,1,1) )
      event_user_a.times.create(time: DateTime.new(2015,1,2), favorite: true)
      event_user_a.times.create(time: DateTime.new(2015,1,3) )
      event_user_b.times.create(time: DateTime.new(2015,1,1) )
      event_user_b.times.create(time: DateTime.new(2015,1,3), favorite: true)
      event_user_c.times.create(time: DateTime.new(2015,1,1) )
      event_user_c.times.create(time: DateTime.new(2015,1,3) )
    end

    describe '#best_date' do
      it 'picks the date with the highest number of RSVPs and favorites' do
        expect(event.best_date).to eq DateTime.new(2015,1,3)
      end
    end

    describe '#scored_dates' do
      it 'returns the dates as json with scores' do
        expect(event.scored_dates).to eq({ "2015-01-01" => { score: 3, favorites: 0, users: [{ name: user_a.name, favorite: false },
                                                                                             { name: user_b.name, favorite: false },
                                                                                             { name: user_c.name, favorite: false }] },
                                           "2015-01-02" => { score: 1, favorites: 1, users: [{ name: user_a.name, favorite: true }] },
                                           "2015-01-03" => { score: 3, favorites: 1, users: [{ name: user_a.name, favorite: false },
                                                                                             { name: user_b.name, favorite: true },
                                                                                             { name: user_c.name, favorite: false }] } })
      end
    end
  end
end
