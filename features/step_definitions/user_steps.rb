# user accessible attrs: :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :repository_ids, :username
#Password doesn't match confirmation
#Email can't be blank
#Password is too short (minimum is 6 characters)
#Password can't be blank

Given /^a user clicks on Help Me Choose$/ do 
  visit("/courses/new")
end

Given /^an admin with username "([^"]*)"$/ do |name|
  @user = FactoryGirl.create(:user, :admin, :username => name, :first_name => 'Admin', :last_name => 'User')
end

Given /^a staff member with username "([^"]*)"$/ do |name|
  @user = FactoryGirl.create(:user, :staff, :username => name, :first_name => 'Staff', :last_name => 'User')
end

Given /^a user with username "([^"]*)"$/ do |name|
  @user = FactoryGirl.create(:user, :username => name, :first_name => 'Test', :last_name => 'User')
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
    click_button "Sign In"
  end
end
Given(/^user logs out$/) do
  click_link("Sign Out")
end

Given(/^admin user goes to Users$/) do
  click_link("Admin Area")
  click_link("Users")
end
Given(/^a user with invalid credentials$/) do
  visit('/users/sign_in')
  find('#user_username').set('badname')
  find('#user_password').set('invalid')
  click_button "Sign In"
end

Given(/^a new user with username "(.*?)"$/) do |name|
  @user = FactoryGirl.build(:user, :username => name, :password => nil, :password_confirmation => nil, :email => nil, :first_name => nil, :last_name => nil)
end


Given(/^"(.*?)" has email "(.*?)"$/) do |name, email|
  if @user && @user.username == name
    @user.email = email
  else 
    raise "Can't set email  due to missing user or username mismatch"
  end
end

Given(/^"(.*?)" has first name "(.*?)"$/) do |name, first_name|
  if @user && @user.username == name
    @user.first_name = first_name
  else 
    raise "Can't set first name due to missing user or username mismatch"
  end
end

Given(/^"(.*?)" has last name "(.*?)"$/) do |name, last_name|
  if @user && @user.username == name
    @user.last_name = last_name
  else
    raise "Can't set last name due to missing user or username mismatch"
  end  
end

Given(/^"(.*?)" has password "(.*?)"$/) do |name, pw|
  if @user && @user.username == name
    @user.password = pw
  else
    raise "Can't set password due to missing user or username mismatch"
  end  
end

Given(/^"(.*?)" has password confirmation "(.*?)"$/) do |name, pwconf|
  if @user && @user.username == name
    @user.password_confirmation = pwconf
  else
    raise "Can't set password confirmation due to missing user or username mismatch"
  end  

end

Given(/^"(.*?)" signs up$/) do |name|
  visit('/users/sign_in')
  find('#new_user_username').set(name)
  find('#user_email').set(@user.email)
  find('#user_first_name').set(@user.first_name)
  find('#user_last_name').set(@user.last_name)
  find('#new_user_password').set(@user.password)
  find('#user_password_confirmation').set(@user.password_confirmation)
  click_button 'Sign Up'
end




Then /^(?:|I )expect to see "([^"]*)"$/ do |text|
    expect(page).to have_content(text)
end

Then /^(?:|I )expect to see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)
  expect(page).to have_xpath('//*', :text => regexp)
end

Then /^(?:|I )do not expect to see "([^"]*)"$/ do |text|
  expect(page).not_to have_content(text)
end

Then /^(?:|I )do not expect to see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)
  expect(page).not_to have_xpath('//*', :text => regexp)
end