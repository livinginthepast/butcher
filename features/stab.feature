Feature: Stab

  Scenario: Usage information
    When I run `stab --help`
    Then the exit status should be 0
    And the output should contain:
    """
    Usage: stab [options]
    """