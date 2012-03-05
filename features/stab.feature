Feature: Stab
  Background:
    Given I could run `knife status` with stdout:
    """
    1 minute ago, app.node, app.domain, 1.1.1.1, os
    """
    And I could run `ssh 1.1.1.1` with stdout:
    """
    yay!
    """

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
    Given a directory named "tmp/test_dir" should not exist
    When I run `stab app.node -c tmp/test_dir`
    Then a directory named "tmp/test_dir" should exist

  Scenario: Don't download node list if already cached
    Given I have the following chef nodes:
      | 1 minute ago | app.node | app.domain | 1.1.1.1 | os |
    Then a file named "tmp/test/node.cache" should exist
    When I run `stab app.node -c tmp/test -v`
    Then the output should not contain "Creating cache file of nodes"

  Scenario: Force download of cache file
    Given pending
    When I run `stab app.node -c tmp/test -f -v`
    Then the output should contain "Creating cache file of nodes"
    And the exit status should be 0
