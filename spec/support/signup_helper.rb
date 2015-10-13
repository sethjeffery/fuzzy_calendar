module SignupHelper

  def signup_in_modal(name = "John Logsdon", email = "john@example.com", password = "pass12345")
    within '.modal.in' do
      click_on "Sign up for a new account"
    end

    within '.wizard-step.active' do
      fill_in_signup_form name, email, password
    end
  end

  def fill_in_signup_form(name = "John Logsdon", email = "john@example.com", password = "pass12345")
    fill_in "Name", with: name
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_on "Sign up"
  end

  def user_is_logged_in
    within '#navbar' do
      expect(page).to have_no_content "Log in"
    end
  end

  def user_is_not_logged_in
    within '#navbar' do
      expect(page).to have_content "Log in"
    end
  end
end
