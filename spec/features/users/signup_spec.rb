require 'rails_helper'

feature "Users::Signup", :js do

  context 'Sign up' do
    scenario 'from navbar' do
      visit root_path

      within '#navbar' do
        click_on "Log in"
      end

      signup_in_modal
      user_is_logged_in
    end

    scenario 'from hamburger menu' do
      visit root_path

      open_hamburger_menu do
        click_on "Sign up"
      end

      fill_in_signup_form
      user_is_logged_in
    end

    scenario 'from link that requires authentication' do
      event = create(:event)
      visit event_path(event)

      click_on 'RSVP'

      signup_in_modal
      user_is_logged_in

      # User remains on event page
      expect(current_path).to eq event_path(event)

      # RSVP modal is auto-open
      within_current_modal do
        expect(page).to have_content "What dates are you available?"
      end
    end

    context 'validation errors' do
      background do
        visit root_path

        within '#navbar' do
          click_on "Log in"
        end
      end

      scenario "with badly formatted email" do
        signup_in_modal "John", "badlyformatted.com", 'pass12345'
        user_is_not_logged_in

        expect(current_path).to eq signup_path
        expect(page).to have_content "Email is invalid"
      end

      scenario "with blank name" do
        signup_in_modal "", "email@example.com", 'pass12345'
        user_is_not_logged_in

        expect(current_path).to eq signup_path
        expect(page).to have_content "Name can't be blank"
      end

      scenario "with blank email" do
        signup_in_modal "John", "", 'pass12345'
        user_is_not_logged_in

        expect(current_path).to eq signup_path
        expect(page).to have_content "Email can't be blank"
      end

      scenario "with blank password" do
        signup_in_modal "John", "email@example.com", ''
        user_is_not_logged_in

        expect(current_path).to eq signup_path
        expect(page).to have_content "Password can't be blank"
      end

      scenario "with duplicate user" do
        create(:user, email: 'email@example.com')

        signup_in_modal "John", "email@example.com", 'pass12345'
        user_is_not_logged_in

        expect(current_path).to eq signup_path
        expect(page).to have_content "Email has already been taken"
      end
    end
  end
end
