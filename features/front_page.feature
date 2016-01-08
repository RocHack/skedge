@selenium
Feature: Front page loads and contains elements

  Background:
    Given I am a Skedge user
    When I load the page

  Scenario: Front page basic elements
    Then I see expected elements

  Scenario: About works
    And I follow the about link
    Then I see the about text

  Scenario: Search works
    And I follow the search link
    Then I see the search text

  Scenario: Department works
    And I follow the department link
    Then I see the department text
