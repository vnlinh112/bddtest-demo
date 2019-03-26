Feature: Subscription
    As a user, I want to manage my subscription

    Background:
        Given there are plans with info:
            | plan_id | plan_name | plan_price | trial_info      |
            | 2       | Basic     | 49.95      | $1 for 7 days   |
            | 3       | Pro       | 299.95     |                 |
            | 4       | Pro trial | 0          | Free for 3 days |
            | 5       | Standard  | 29.95      |                 |

    Scenario: preparing users
        Given there are users with info:
            | email           | password | current_plan | trial_info      | remaining_day | intention              | expectation                                               |
            | user1@test.com  | iop890   |              |                 |               | subscribe Basic plan   | get 7 days trial with $1 for Basic plan, then $49.95/m    |
            | user2@test.com  | iop890   | Basic        | $1 for 7 days   | 2             | subscribe Basic plan   | duplicated plan, not allowed, still can use app           |
            | user5@test.com  | iop890   | Basic        | $1 for 7 days   | 0             | subscribe again        | subscribe plan 2 without trial                            |
            | user6@test.com  | iop890   |              |                 |               | subscribe Pro plan     | subscribe plan 3 with first month $299.95                 |
            | user7@test.com  | iop890   | Basic        |                 | 0             | upgrade to Pro plan    | subscribe plan 3 with first month $299.95                 |
            | user8@test.com  | iop890   | Basic        |                 | 10            | upgrade to Pro plan    | subscribe plan 3 with first month $283.3                  |
            | user10@test.com | iop890   | Pro          |                 | 0             | not pay for next month | subscription expired, cannot use app                      |
            | user12@test.com | iop890   | Basic        | $1 for 7 days   | 2             | subscribe Pro trial    | not allowed, still on current plan                        |
            | user13@test.com | iop890   | Basic        | $1 for 7 days   | 0             | subscribe Pro trial    | not allowed, account expire                               |
            | user14@test.com | iop890   | Pro          |                 | 0             | subscribe Pro trial    | not allowed, account expire                               |
            | user15@test.com | iop890   | Pro trial    | Free for 3 days | 2             | subscribe Pro trial    | not allowed, still on current plan                        |
            | user16@test.com | iop890   | Pro trial    | Free for 3 days | 0             | subscribe Pro trial    | not allowed, account expire                               |
            | user17@test.com | iop890   | Pro trial    | Free for 3 days | 2             | subscribe Basic        | subscribe plan 2 with first month $49.95                  |
            | user18@test.com | iop890   | Pro trial    | Free for 3 days | 0             | subscribe Pro          | subscribe plan 3 with first month $299.95                 |
            | user19@test.com | iop890   | Pro trial    | Free for 3 days | 2             | upgrade then cancel    | still on current plan                                     |
            | user21@test.com | iop890   | Basic        |                 | 0             | pay for next month     | transaction is saved to db, exp is extended, sub active   |


    Scenario Outline: user subscribe to visible plan successfully
        Given I login with email <email> and password <password>
        Then I should be redirected to "/subscription"
        When I choose plan <plan_id> with name <plan_name>
        Then I should see modal with title "Redirect you to Paypal"
        And I should be redirected to Paypal
        When I login Paypal
        Then I should see Paypal note from seller <plan_paypal_memo>
        When I confirm Paypal payment and be charged <amount_charged>
        Then I should be redirected to thankyou page
        And I should be redirected to "/product/trending" to use app
        When I visit url "/subscription"
        Then I should see my current plan is <plan_id> with name <plan_name> and status "Active"
        And I should see next billing date is <remaining_day> days from now
        And I should see Paypal billing agreement info which looks like "I-R52P15A2REAP"

        Examples: as a new user, I want to make subscription
            | email             | password | plan_id | plan_name | amount_charged | remaining_day | plan_paypal_memo                                                            |
            | user1@test.com    | iop890   | 2       | Basic     | 1              | 7             | Bigbigproduct Basic Plan - $1 TRIAL FOR 7 DAYS, then $49.95. Cancel anytime |
            | user6@test.com    | iop890   | 3       | Pro       | 299.95         | 30            | Bigbigproduct Pro Plan                                                      |

        Examples: as a user with expired subscription, I want to subscribe again or upgrade
            | email             | password | plan_id | plan_name | amount_charged | remaining_day | plan_paypal_memo                                                            |
            | user5@test.com    | iop890   | 2       | Basic     | 49.95          | 30            | Bigbigproduct Basic Plan - $1 TRIAL FOR 7 DAYS, then $49.95. Cancel anytime |
            | user7@test.com    | iop890   | 3       | Pro       | 299.95         | 30            | Bigbigproduct Pro Plan                                                      |
            | user18@test.com   | iop890   | 3       | Pro       | 299.95         | 30            | Bigbigproduct Pro Plan                                                      |

        Examples: as a user with active subscription, I want to upgrade
            | email             | password | plan_id | plan_name | amount_charged | remaining_day | plan_paypal_memo                                                            |
            | user4@test.com    | iop890   | 3       | Pro       | 299.95         | 30            | Bigbigproduct Pro Plan                                                      |
            | user8@test.com    | iop890   | 3       | Pro       | 299.95         | 30            | Bigbigproduct Pro Plan                                                      |
            | user17@test.com   | iop890   | 2       | Basic     | 49.95          | 30            | Bigbigproduct Basic Plan - $1 TRIAL FOR 7 DAYS, then $49.95. Cancel anytime |


    Scenario: user is not allowed to subscribe again to his current active plan
        Given I login with email "user2@test.com" and password "iop890"
        When I visit url "/subscription"
        Then I should see my current plan is "2" with name "Basic" and status "Active"
        When I visit url "/subscription?plan=2"
        Then I should see "warning" message "You are already on this plan!"
        And I should see my current plan is "2" with name "Basic" and status "Active"

    Scenario: user does not pay for next month should have account expired and cannot use app
        Given I login with email "user10@test.com" and passwordd "iop890"
        And today is my next billing date and I have not paid yet
        When I visit url "/subscription"
        Then I should see "error" message "Your subscription has expired. Please subscribe again!"
        When I visit url "/product/trending"
        Then I should be redirected to "/subscription"

    Scenario Outline: user who have active subscription is not allowed to get trial subscription
        Given I login with email <email> and password <password>
        When I visit url "/subscription"
        Then I should see my current plan is <plan_id> with name <plan_name> and status "Active"
        When I visit url "/subscription?plan=4"
        Then I should be redirected to "/subscription"
        And I should see "warning" message "If you want to downgrade or cancel subscription, please contact support@bigbigproduct.com"
        And I should see my current plan is <plan_id> with name <plan_name> and status "Active"

        Examples:
            | email           | password | plan_id      | plan_name    |
            | user12@test.com | iop890   | 2            | Basic        |
            | user15@test.com | iop890   | 4            | Pro trial    |

    Scenario Outline: user who have expired subscription is not allowed to get trial subscription and have account expired
        Given I login with email <email> and password <password>
        When I visit url "/subscription"
        Then I should see "warning" message "Your subscription has expired. Please subscribe again!"
        When I visit url "/subscription?plan=4"
        Then I should be redirected to "/subscription"
        And I should see "warning" message "Sorry, this plan is not available. Please choose another plan."
        When I visit url "/product/trending"
        Then I should be redirected to "/subscription"

        Examples:
            | email           | password | plan_id | plan_name |
            | user13@test.com | iop890   | 2       | Basic     |
            | user14@test.com | iop890   | 3       | Pro       |
            | user16@test.com | iop890   | 4       | Pro trial |

    Scenario: user pay for next month before expire to continue subscription
        Given I login with email "user21@test.com" and password "iop890"
        When today is my next billing date
        And I pay for next month to continue subscription
        And I visit url "/subscription"
        Then I should see my current plan is "2" with name "Basic" and status "Active"
        And I should see next billing date is "30" days from now
