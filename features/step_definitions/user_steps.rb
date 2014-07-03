# user accessible attrs: :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :repository_ids, :username
#Password doesn't match confirmation
#Email can't be blank
#Password is too short (minimum is 6 characters)
#Password can't be blank

Given(/^a staff user named "(.*?)"$/) do |name|
#Given /^a staff user named  "([^"]*)"$/ do |name|
  @user = FactoryGirl.create(:user, :username => name, :password => 'staffpassword', :staff => true)
end

Given /^a user named "([^"]*)"$/ do |name|
  @user = FactoryGirl.create(:user, :username => name, :password => 'password')
end

Given /^(?:"([^"]*)"|user) logs in$/ do |name|
  unless name
    if @user
      name = @user.username
      passw = @user.password
    else
      raise "Log in whom, exactly?"
    end
  end
  visit('/users/sign_in')
  within "#welcome-left" do
    fill_in "Username", :with => name
    fill_in "Password", :with => passw
    click_button "Sign in"
  end
end
Given(/^user logs out$/) do
  click_link("Sign Out")
end

Given(/^a user with invalid credentials$/) do
  visit('/users/sign_in')
  within "#welcome-left" do
    fill_in "Username", :with => 'badname'
    fill_in "Password", :with => 'invalid'
    click_button "Sign in"
  end
end

Given(/^a new user named "(.*?)"$/) do |name|
  @user = FactoryGirl.build(:user, :username => name, :email => '')
end


Given(/^"(.*?)" has email of "(.*?)"$/) do |name, email|
  if @user && @user.username == name
    @user.email = email
  else 
    raise "Can't set email  due to missing user or username mismatch"
  end
end

Given(/^"(.*?)" has first of "(.*?)"$/) do |name, first_name|
  if @user && @user.username == name
    @user.first_name = first_name
  else 
    raise "Can't set first name due to missing user or username mismatch"
  end
end

Given(/^"(.*?)" has last of "(.*?)"$/) do |name, last_name|
  if @user && @user.username == name
    @user.last_name = last_name
  else
    raise "Can't set last name due to missing user or username mismatch"
  end  
end

Given(/^"(.*?)" has password of "(.*?)"$/) do |name, pw|
  if @user && @user.username == name
    @user.password = pw
  else
    raise "Can't set password due to missing user or username mismatch"
  end  
end

Given(/^"(.*?)" has pwconf of "(.*?)"$/) do |name, pwconf|
  if @user && @user.username == name
    @user.password_confirmation = pwconf
  else
    raise "Can't set password confirmation due to missing user or username mismatch"
  end  

end

Given(/^"(.*?)" signs up$/) do |name|
  visit('/users/sign_in')
  within "#welcome-right" do
    fill_in "Username", :with => name
    fill_in "Email", :with => @user.email
    fill_in "First name", :with => @user.first_name
    fill_in "Last name", :with => @user.last_name
    fill_in "Password", :with => @user.password
    fill_in "Password confirmation", :with => @user.password_confirmation
    click_button "Sign up"
  end
end




Then /^(?:|I )should see "([^"]*)"$/ do |text|
#  binding.pry
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


