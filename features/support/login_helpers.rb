module LoginHelpers

  def logout_and_login_user(username = "kassi_testperson1", password = "testi")
    logout() if @current_user
    login_user(username, password)
  end

  def login_user(username = "kassi_testperson1", password = "testi")
    visit login_path(:locale => :en)
    fill_in("main_person_login", :with => username)
    fill_in("main_person_password", :with => password)
    click_button(:main_log_in_button)

    # Warning! This sets @current_user even if the login fails.
    # This should be fixed.
    @current_user = Person.find_by(username: username)
  end

  def logout()
    steps %Q{
      When I open user menu
    }
    click_link "Log out"

    @current_user = nil
  end

  # No browser interaction
  def login_user_without_browser(username)
    person = Person.find_by(username: username)
    Warden::Test::Helpers.login_as(person, :scope => :person)
    visit homepage_with_locale_path(:locale => :en)
    @logged_in_user = person
    @current_user = person
  end

  # Log out current user without browser interaction
  def logout_user_without_browser
    # Use logout Warden helper
    Warden::Test::Helpers.logout
  end

end

World(LoginHelpers)
