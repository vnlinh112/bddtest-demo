Feature: Login
    As a user, I want to login so that I can use the app.

    Scenario: Login with valid account
        Given there is an account with email "new_user@test.com" and password "1234567"
        When I visit url "/a/login"
        And I enter email with "new_user@test.com"
        And I enter password with "987"
        And I click button "Login to start working"
        Then I should see notification "Successfully login with email new_user@test.com"

    @watch
    Scenario: Login with invalid account
        Given there is no account with email "invalid@test.com" and password "1234567"
        When I visit url "/a/login"
        And I enter email with "new_user@test.com"
        And I enter password with "987"
        And I click button "Login to start working"
        Then I should see a dialog with message "Invalid email or password"
