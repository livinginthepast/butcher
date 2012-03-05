Feature: Stab

  Scenario: Usage information with --help option
    When I run `stab --help`
    Then the exit status should be 0
    And the output should contain:
    """
    Usage: stab [options] node_name
    """

  Scenario: Usage information when no node name is given
    When I run `stab`
    Then the exit status should be 64
    And the output should contain:
    """
    Usage: stab [options] node_name
    """

  Scenario: Invalid option
    When I run `stab --invalid-option`
    Then the exit status should be 64
    And the output should contain:
    """
    invalid option: --invalid-option
    Usage: stab [options] node_name
    """

  Scenario: Set cache directory
    When I run `stab app.node -c tmp/test`
    Then a directory named "tmp/test" should exist
