Feature: User Actions
  In order to allow anything to happen,
  Users have to work.

Scenario: Make a User
  Given a user named "test_user"
  And "test_user" logs in
  Then I should see "Signed in successfully."
