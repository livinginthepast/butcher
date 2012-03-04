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

  Scenario: User connects to listed node name
    Given pending
    Given I have the following chef nodes:
      | 1 hour ago | app.node | app.domain | 192.168.0.1 | os |
    And I could run `ssh 192.168.0.1` with stdout:
    """
    SSH success!
    """

    When I run `stab app.node`
    And the exit status should be 0
    And the output should contain:
    """
    SSH success!
    """