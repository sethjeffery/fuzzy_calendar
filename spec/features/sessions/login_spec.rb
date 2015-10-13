require 'rails_helper'

feature "Sessions::Login", :js do
  let!(:user) { create(:user, password: 'pass12345') }

  context 'Log in with Fuzzy account' do
    scenario 'from navbar' do
      visit root_path

      within '#navbar' do
        click_on "Log in"
      end

      within_current_modal do
        fill_in_login_form user.email, user.password
      end

      user_is_logged_in
    end

    scenario 'from hamburger menu' do
      visit root_path

      find('.navbar-toggler').click

      open_hamburger_menu do
        click_on "Log in"
      end

      within_current_modal do
        fill_in_login_form user.email, user.password
      end

      user_is_logged_in
    end

    scenario 'from link that requires authentication' do
      event = create(:event)
      visit event_path(event)

      click_on 'RSVP'

      within_current_modal do
        fill_in_login_form user.email, user.password
      end

      user_is_logged_in

      # User remains on event page
      expect(current_path).to eq event_path(event)

      # RSVP modal is auto-open
      within_current_modal do
        expect(page).to have_content "What dates are you available?"
      end
    end
  end

  scenario "Log in incorrectly" do
    visit root_path

    within '#navbar' do
      click_on "Log in"
    end

    within_current_modal do
      fill_in_login_form "wrong@example.com", "ohsowrong"
    end

    user_is_not_logged_in

    expect(current_path).to eq login_path
    expect(page).to have_content "Could not find your user. Please check your email and password."
  end
end
