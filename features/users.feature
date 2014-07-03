Feature: User Actions
  In order to allow anything to happen,
  Users have to work.

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
