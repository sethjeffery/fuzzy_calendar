require 'rails_helper'

feature "Events::New", :js do
  let!(:user) { create(:user) }
  let(:start_date) { Date.today + 10.days }
  let(:end_date)   { Date.today + 20.days }

  context 'Create a new event' do
    scenario 'with day specificity' do
      login_user user
      visit new_event_path

      fill_in "Enter a name for your event", with: "Event name"

      click_dates('#event_date_range', start_date, end_date)

      expect(page).to have_css(".picker-cell[data-date='#{start_date.strftime('%F')}'].picker-cell-active")
      expect(page).to have_css(".picker-cell[data-date='#{end_date.strftime('%F')}'].picker-cell-active")

      click_on "Create your event"

      expect(current_path).to eq event_path(Event.last)
      expect(page).to have_content 'Event name'
      expect(page).to have_content "This event's final date is still undecided"
    end

    scenario 'with week specificity' do
      login_user user
      visit new_event_path

      fill_in "Enter a name for your event", with: "Event name"
      find('#event_specificity_week + .c-indicator').click

      click_dates('#event_date_range', start_date, end_date)

      expect(page).to have_css(".picker-row[data-date='#{start_date.beginning_of_week(:sunday).strftime('%F')}'].picker-row-active")
      expect(page).to have_css(".picker-row[data-date='#{end_date.beginning_of_week(:sunday).strftime('%F')}'].picker-row-active")

      click_on "Create your event"

      expect(current_path).to eq event_path(Event.last)
      expect(page).to have_content 'Event name'
      expect(page).to have_content "This event's final week is still undecided"
    end

    scenario 'with invalid params' do
      login_user user
      visit new_event_path
      click_on "Create your event"

      expect(current_path).to eq events_path
      expect(page).to have_content 'Please give your event a name.'
      expect(page).to have_content 'Please specify the start and end date.'
    end
  end
end
