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
    Then the exit status should be 0
    And the output should contain:
    """
    Usage: stab [options] node_name
    """

#  Scenario: User connects to listed node name
#    Given I have a chef node named "app.node"
#    When I run `stab app.node`
#    Then I should be connected to "app.node"