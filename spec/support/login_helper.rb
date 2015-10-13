module LoginHelper
  def login_user(user)
    visit login_path
    within '#login_form' do
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_on "Log in"
    end
    expect(page).not_to have_content "Log in"
  end

  def fill_in_login_form(email, password)
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_on "Log in"
  end
end
