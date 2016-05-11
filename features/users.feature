Feature: User Actions
  In order to allow anything to happen,
  Users have to work.

Scenario: Unsigned in user
   Given a user clicks on Help Me Choose
   Then I expect to see "To continue, you will need an account so we can communicate with you"
   And I expect to see "Sign In/Sign Up"

Scenario: Navigate as an admin user
  Given an admin with username "adminuser_test"
  And user logs in
  And admin user goes to Users
  Then I expect to see "First Name"
  And I expect to see "Edit"

Scenario: Sign in an admin user
  Given an admin with username "adminuser_test"
  And user logs in
  Then I expect to see "Signed in successfully."
  And I expect to see "Welcome, Admin User"
  And I expect to see "Dashboard"
  And I expect to see "Admin Area"
  And I do not expect to see "My Classes"

Scenario: Sign in a staff user
  Given a staff member with username "staffuser_test"
  And user logs in
  Then I expect to see "Signed in successfully."
  And I expect to see "Welcome, Staff User"
  And I expect to see "Dashboard"
  And I do not expect to see "Admin Area"
  And I do not expect to see "My Classes"

Scenario: user logs out
  Given a user with username "test_user"
  And user logs in
  And user logs out
  Then I expect to see "Signed out successfully."
  And I expect to see "Sign In/Sign Up"
  And I do not expect to see "Edit Account"
  And I do not expect to see "Sign Out"

Scenario: Try to create new account with missing required information
  Given a new user with username "incomplete_user"
  And "incomplete_user" has first name "Ima"
  And "incomplete_user" has last name "Incomplete"
  And "incomplete_user" signs up
  Then I expect to see "2 errors prohibited this user from being saved:"
  And I expect to see "Email can't be blank"
  And I expect to see "Password can't be blank"

Scenario: Try to create new account with too-short password
  Given a new user with username "incomplete_user"
  And "incomplete_user" has first name "Ima"
  And "incomplete_user" has last name "Incomplete"
  And "incomplete_user" has email "me@bar.com"
  And "incomplete_user" has password "1234b"
  And "incomplete_user" has password confirmation "1234b"
  And "incomplete_user" signs up
  Then I expect to see "1 error prohibited this user from being saved:"
  And I expect to see "Password is too short"

Scenario: Try to create new account with password/confirmation mis-match
  Given a new user with username "incomplete_user"
  And "incomplete_user" has first name "Ima"
  And "incomplete_user" has last name "Incomplete"
  And "incomplete_user" has email "me@bar.com"
  And "incomplete_user" has password "123456b"
  And "incomplete_user" has password confirmation "1234b"
  And "incomplete_user" signs up
  Then I expect to see "1 error prohibited this user from being saved:"
  And I expect to see "Password confirmation doesn't match Password"

Scenario: Sign in a  User
  Given a user with username "test_user"
  And user logs in
  Then I expect to see "Signed in successfully."
  And I expect to see "Welcome, Test User"
  And I do not expect to see "Dashboard"


Scenario: Reject invalid sign-in  credentials
  Given a user with invalid credentials
  Then I expect to see "Invalid username or password."

Scenario: Create a New Account
  Given a new user with username "new_user"
  And "new_user" has email "newest@foo.com"
  And "new_user" has first name "New"
  And "new_user" has last name "User"
  And "new_user" has password "newPw111"
  And "new_user" has password confirmation "newPw111"
  And "new_user" signs up
  Then I expect to see "Welcome! You have signed up successfully"
  And I expect to see "Welcome, New User"

Scenario: Create a Minimal Account
  Given a new user with username "new_user"
  And "new_user" has email "newest@foo.com"
  And "new_user" has password "newPw111"
  And "new_user" has password confirmation "newPw111"
  And "new_user" signs up
  Then I expect to see "Welcome! You have signed up successfully"
  And I expect to see "Welcome, new_user"

