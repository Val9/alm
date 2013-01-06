Feature: Show errors
  In order to make sure that we collect metrics correctly
  An admin user
  Should see errors

  Background:
    Given I am logged in
    And that we have 2 error messages
    
    @javascript
    Scenario: Seeing a list of errors
      When I go to the "Errors" admin page
      Then I should see 2 error messages
    
    @javascript
    Scenario Outline: Seeing error information
      When I go to the "Errors" admin page
      Then I should see the "<Message>" error message
      And I should see the "<ClassName>" class name
      And I should not see the "<TargetUrl" target url
      
      Examples: 
        | Message                         | ClassName                    | TargetUrl                  |
        | Couldn't find Source with id=x  | ActiveRecord::RecordNotFound | http://127.0.0.1/sources/x |
    
    @javascript
    Scenario Outline: Seeing error details
    When I go to the "Errors" admin page
    And I click on the "More" button
    Then I should see the "<TargetUrl" target url
      
      Examples: 
        | TargetUrl                  |
        | http://127.0.0.1/sources/x |
    
    @javascript
    Scenario Outline: Routing errors
      When I go to "<Path>"
      Then I should see the "<ErrorMessage>" error message
      And I should see the "<ErrorNumber>" error number
      
      Examples: 
        | Path        | ErrorNumber | ErrorMessage |
        | /sources/x  | 404         | Page not found |
