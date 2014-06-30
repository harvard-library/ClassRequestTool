Given /^a user named "([^"]*)"$/ do |name|
  @user = FactoryGirl.create(:user, :username => name, :password => 'password')
end

Given /^(?:"([^"]*)"|user) logs in$/ do |name|
  unless name
    if @user
      name = @user.username
    else
      raise "Log in whom, exactly?"
    end
  end
  visit('/users/sign_in')
  within "#welcome-left" do
    fill_in "Username", :with => name
    fill_in "Password", :with => 'password'
    click_button "Sign in"
  end
end

Then /^(?:|I )should see "([^"]*)"$/ do |text|
  if page.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
end

Then /^(?:|I )should see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)

  if page.respond_to? :should
    page.should have_xpath('//*', :text => regexp)
  else
    assert page.has_xpath?('//*', :text => regexp)
  end
end

Then /^(?:|I )should not see "([^"]*)"$/ do |text|
  if page.respond_to? :should
    page.should have_no_content(text)
  else
    assert page.has_no_content?(text)
  end
end

Then /^(?:|I )should not see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)

  if page.respond_to? :should
    page.should have_no_xpath('//*', :text => regexp)
  else
    assert page.has_no_xpath?('//*', :text => regexp)
  end
end
