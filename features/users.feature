Feature: User Actions
  In order to allow anything to happen,
  Users have to work.

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
  And "test_user" logs in
  Then I should see "Signed in successfully."

Scenario: Sign in a  User with welcome
  Given a user named "test_user"
  And "test_user" logs in
  Then I should see "Signed in successfully." 
  And I should see "Welcome, test_user"

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

