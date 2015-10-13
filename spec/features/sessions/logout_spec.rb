require 'rails_helper'

feature "Sessions::Logout", :js do
  let!(:user) { create(:user, password: 'pass12345') }

  context 'Log out' do
    scenario 'from user menu' do
      login_user user
      visit root_path

      click_on user.name

      within '.dropdown-menu' do
        click_on 'Log out'
      end

      # User is logged out
      within '#navbar' do
        expect(page).to have_no_content user.name
        expect(page).to have_content 'Log in'
      end
    end

    scenario 'from hamburger menu' do
      login_user user
      visit root_path

      find('.navbar-toggler').click

      within '#hamburger-menu' do
        click_on "Log out"
      end

      # User is logged out
      within '#navbar' do
        expect(page).to have_no_content user.name
        expect(page).to have_content 'Log in'
      end
    end
  end
end
