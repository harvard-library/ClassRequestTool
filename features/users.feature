Feature: User Actions
  In order to allow anything to happen,
  Users have to work.

Scenario: Navigate as an admin user
  Given an admin user named "adminuser_test"
  And user logs in
  And admin user goes to Users
  Then I should see "First Name"
  And I should see "Actions"

Scenario: Sign in an admin user
  Given an admin user named "adminuser_test"
  And user logs in
  Then I should see "Signed in successfully."
  And I should see "Welcome, adminuser_test"
  And I should see "Dashboard"
  And I should see "Admin Area"
  And I should not see "My Classes"

Scenario: Sign in a staff user
  Given a staff user named "staffuser_test"
  And user logs in
  Then I should see "Signed in successfully."
  And I should see "Welcome, staffuser_test"
  And I should see "Dashboard"
  And I should not see "Admin Area"
  And I should not see "My Classes"

Scenario: user logs out
  Given a user named "test_user"
  And user logs in
  And user logs out
  Then I should see "Signed out successfully."
  And I should see "Sign In/Sign Up"
  And I should not see "Edit Account"
  And I should not see "Sign Out"

Scenario: Try to create new account with missing required information
  Given a new user named "incomplete_user"
  And "incomplete_user" has first of "Ima"
  And "incomplete_user" has last of "Incomplete"
  And "incomplete_user" signs up
  Then I should see "2 errors prohibited this user from being saved:"
  And I should see "Email can't be blank"
  And I should see "Password can't be blank"

Scenario: Try to create new account with too-short password
  Given a new user named "incomplete_user"
  And "incomplete_user" has first of "Ima"
  And "incomplete_user" has last of "Incomplete"
  And "incomplete_user" has email of "me@bar.com"
  And "incomplete_user" has password of "1234b"
  And "incomplete_user" has pwconf of "1234b"
  And "incomplete_user" signs up
  Then I should see "1 error prohibited this user from being saved:"
  And I should see "Password is too short"

Scenario: Try to create new account with password/confirmation mis-match
  Given a new user named "incomplete_user"
  And "incomplete_user" has first of "Ima"
  And "incomplete_user" has last of "Incomplete"
  And "incomplete_user" has email of "me@bar.com"
  And "incomplete_user" has password of "123456b"
  And "incomplete_user" has pwconf of "1234b"
  And "incomplete_user" signs up
  Then I should see "1 error prohibited this user from being saved:"
  And I should see "Password doesn't match confirmation"

Scenario: Sign in a  User
  Given a user named "test_user"
  And user logs in
  Then I should see "Signed in successfully."
  And I should see "Welcome, test_user"
  And I should not see "Dashboard"


Scenario: Reject invalid sign-in  credentials
  Given a user with invalid credentials
  Then I should see "Invalid email or password."

Scenario: Create a New Account
  Given a new user named "new_user"
  And "new_user" has email of "newest@foo.com"
  And "new_user" has first of "New"
  And "new_user" has last of "User"
  And "new_user" has password of "newPw111"
  And "new_user" has pwconf of "newPw111"
  And "new_user" signs up
  Then I should see "Welcome! You have signed up successfully"
  And I should see "Welcome, New User"

Scenario: Create a Minimal Account
  Given a new user named "new_user"
  And "new_user" has email of "newest@foo.com"
  And "new_user" has password of "newPw111"
  And "new_user" has pwconf of "newPw111"
  And "new_user" signs up
  Then I should see "Welcome! You have signed up successfully"
  And I should see "Welcome, new_user"

