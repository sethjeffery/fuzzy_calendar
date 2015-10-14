require 'rails_helper'

feature "Events::Show", :js do
  let(:creator) { create(:creator) }
  let(:user) { create(:user) }

  context 'RSVP to day event' do
    let!(:event) { create(:event, creator: creator, starts_at: Date.today, ends_at: Date.today + 1.month) }

    scenario 'not logged in' do
      visit event_path event

      expect(page).to have_css ".btn-primary.btn-glow[href=\"#{event_path(event)}#rsvp\"]"

      click_on "RSVP"
      expect(page).to have_css '#login-modal.in'

      within_current_modal do
        fill_in_login_form user.email, user.password
      end

      expect(page).to have_css '#event-rsvp-modal.in'

      within_current_modal do
        click_dates('#picker-rsvp-available', Date.today, Date.today + 1.day, Date.today + 2.days)
        expect(page).to have_css(".picker-cell[data-date='#{Date.today.strftime('%F')}'].picker-cell-active")
        expect(page).to have_css(".picker-cell[data-date='#{(Date.today + 1.day).strftime('%F')}'].picker-cell-active")
        expect(page).to have_css(".picker-cell[data-date='#{(Date.today + 2.days).strftime('%F')}'].picker-cell-active")

        find('.btn-primary[data-move="next"]').click

        click_dates('#picker-rsvp-favorites', Date.today) # highlight first date only
        expect(page).to have_css(".picker-cell[data-date='#{Date.today.strftime('%F')}'].picker-cell-favorite")
        expect(page).to have_no_css(".picker-cell[data-date='#{(Date.today + 1.day).strftime('%F')}'].picker-cell-favorite")
        expect(page).to have_no_css(".picker-cell[data-date='#{(Date.today + 2.days).strftime('%F')}'].picker-cell-favorite")

        click_on "Done"
      end

      expect(page).to have_css("#event-dates .picker-cell[data-date='#{Date.today.strftime('%F')}'].picker-cell-active")
      expect(page).to have_css("#event-dates .picker-cell[data-date='#{(Date.today + 1.day).strftime('%F')}'].picker-cell-active")
      expect(page).to have_css("#event-dates .picker-cell[data-date='#{(Date.today + 2.days).strftime('%F')}'].picker-cell-active")

      within '.event-attendees' do
        expect(page).to have_text user.name
      end

      expect(ActionMailer::Base.deliveries).to be_present
      expect(ActionMailer::Base.deliveries.first.to).to eq([event.creator.email])
    end
  end

  context 'RSVP to week event' do
    let(:start) { Date.today.beginning_of_week(:sunday) }
    let!(:event) { create(:event, specificity: 'week', creator: creator, starts_at: start + 1.week, ends_at: start + 5.weeks) }

    scenario 'logged in' do
      login_user user
      visit event_path event

      expect(page).to have_css '.btn-primary.btn-glow[href="#event-rsvp-modal"]'

      click_on "RSVP"
      expect(page).to have_css '#event-rsvp-modal.in'

      within_current_modal do
        click_dates('#picker-rsvp-available', Date.today + 2.weeks, Date.today + 3.weeks)
        expect(page).to have_css(".picker-row[data-date='#{(start + 2.weeks).strftime('%F')}'].picker-row-active")
        expect(page).to have_css(".picker-row[data-date='#{(start + 3.weeks).strftime('%F')}'].picker-row-active")

        find('.btn-primary[data-move="next"]').click

        click_dates('#picker-rsvp-favorites', Date.today + 2.weeks) # highlight one week only
        expect(page).to have_css(".picker-row[data-date='#{(start + 2.weeks).strftime('%F')}'].picker-row-favorite")
        expect(page).to have_no_css(".picker-row[data-date='#{(start + 3.weeks).strftime('%F')}'].picker-row-favorite")

        click_on "Done"
      end

      expect(page).to have_css("#event-dates .picker-row[data-date='#{(start + 2.weeks).strftime('%F')}'].picker-row-active")
      expect(page).to have_css("#event-dates .picker-row[data-date='#{(start + 3.weeks).strftime('%F')}'].picker-row-active")

      within '.event-attendees' do
        expect(page).to have_text user.name
      end

      expect(ActionMailer::Base.deliveries).to be_present
      expect(ActionMailer::Base.deliveries.first.to).to eq([event.creator.email])
    end
  end

  context 'close event' do
    let(:event) { create(:event, creator: creator) }
    let(:attendee) { create(:user) }

    background do
      event.event_users.create! user: attendee
    end

    it 'cannot be performed by attendee' do
      login_user attendee
      visit event_path event
      expect(page).to have_no_content "Edit"
    end

    it 'can be performed by creator' do
      login_user creator
      visit event_path event
      expect(page).to have_link "RSVP"

      click_on "Edit"
      click_on "Close event"

      within_current_modal do
        click_on "Close event"
      end

      expect(page).to have_content "The event is now closed"
      expect(page).to have_no_link "RSVP"

      expect(ActionMailer::Base.deliveries).to be_present
      expect(ActionMailer::Base.deliveries.first.to).to eq([attendee.email])
    end
  end

  context 'finalise event' do
    let(:event) { create(:event, creator: creator) }
    let(:attendee) { create(:user) }

    it 'can be performed by creator' do
      login_user creator
      visit event_path event
      expect(page).to have_link "RSVP"

      click_on "Edit"
      expect(page).to have_no_content "Finalise event date"
      find_link("Edit").trigger('click')

      click_on "RSVP"

      within_current_modal do
        click_dates('#picker-rsvp-available', Date.today)
        find('.btn-primary[data-move="next"]').click
        click_on "Done"
      end

      click_on "Edit"
      click_on "Finalise event date"

      # In the mean time, add an attendee...
      event.event_users.create! user: attendee

      within_current_modal do
        expect(page).to have_content Date.today.strftime('%A, %-d %B %Y')
        expect(page).to have_css("#picker-rsvp-finalise .picker-cell[data-date='#{Date.today.strftime('%F')}'].picker-cell-active")

        # pick different date
        click_dates('#picker-rsvp-finalise', Date.tomorrow)
        click_on "Finalise!"
      end

      expect(page).to have_content "This event's date has been finalised"
      expect(page).to have_content Date.tomorrow.strftime('%A, %-d %B %Y')
      expect(page).to have_no_link "RSVP"

      expect(ActionMailer::Base.deliveries).to be_present
      expect(ActionMailer::Base.deliveries.first.to).to eq([attendee.email])
    end
  end
end
