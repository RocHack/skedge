@selenium
Feature: As a student
  I want to be able to search for courses
  So that I may enroll to those that interest me

  Background:
    Given I am a Skedge user
    When I load the page

  Scenario: Being able to search for a course
    When I search for "CSC 108"
    Then I should see its description as "CSC108"
