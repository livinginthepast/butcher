Feature: Stab

  Background:
    Given I double `knife status` with stdout:
    """
    1 minute ago, app.node, app.domain, 1.1.1.1, os
    """
    Given I have a knife configuration file
    And I double `ssh 1.1.1.1` with stdout:
    """
    ssh yay!
    """

  Scenario: Usage information with --help option
    When I run `stab --help`
    Then the exit status should be 0
    And the output should contain:
    """
    Usage: stab [options] <node name> [ssh options]
    """

  Scenario: Usage information when no node name is given
    When I run `stab`
    Then the exit status should be 64
    And the output should contain:
    """
    Usage: stab [options] <node name> [ssh options]
    """

  Scenario: Tell user what IP address ssh uses
    Given I have the following chef nodes:
      | 1 minute ago | app.node | app.domain | 1.1.1.1 | os |
    When I run `stab app.node -v`
    Then the output should contain "Connecting to app.node at 1.1.1.1"
    Then the output should contain "ssh yay!"

  Scenario: Don't download node list if already cached
    Given I have the following chef nodes:
      | 1 minute ago | app.node | app.domain | 1.1.1.1 | os |
    Then a file named "tmp/test/.butcher/cache/my_organization.cache" should exist
    When I run `stab app.node -v`
    Then the output should not contain "Creating cache file of nodes"

  Scenario: Force download of cache file
    Given I have the following chef nodes:
      | 1 minute ago | app.node | app.domain | 1.1.1.1 | os |
    When I run `stab app.node -f -v`
    Then the output should contain "Creating cache file of nodes"
    And the exit status should be 0
    And the double `knife status` should have been run

  Scenario: User sees error message if no node matches given name
    Given I have the following chef nodes:
      | 1 minute ago | app.node | app.domain | 1.1.1.1 | os |
    When I run `stab some.node`
    Then the stderr should contain:
    """
    Unable to find node "some.node"
    """
    And the exit status should be 65

  Scenario: User sees error message if multiple nodes match given name
    Given I have the following chef nodes:
      | 1 minute ago | other.node | other.domain | 1.1.1.2 | os |
      | 1 minute ago | app.node   | app.domain   | 1.1.1.1 | os |
    When I run `stab node`
    Then the stderr should contain:
    """
    Multiple nodes match "node"
    ["app.node", "app.domain"] => 1.1.1.1
    ["other.node", "other.domain"] => 1.1.1.2
    """
    And the exit status should be 66

  Scenario: User can connect to server with given user name
    Given I have the following chef nodes:
      | 1 minute ago | app.node | app.domain | 1.1.1.1 | os |
    Given I double `ssh 1.1.1.1 -l user` with stdout:
    """
    user: I'm a computer!
    """
    When I run `stab app.node -l user`
    Then the stdout should contain:
    """
    user: I'm a computer!
    """

  Scenario: Arbitrary command line options are passed to ssh
    Given I have the following chef nodes:
      | 1 minute ago | app.node | app.domain | 1.1.1.1 | os |
    Given I double `ssh 1.1.1.1 -l user --arrrh`
    When I run `stab app.node -l user --arrrh`
    Then the double `ssh 1.1.1.1 -l user --arrrh` should have been run

  Scenario: User sees error message if knife.rb cannot be found
    Given I don't have a knife configuration file
    When I run `stab app.node`
    Then the stderr should contain:
    """
    Unable to find knife.rb in ./.chef
    Are you stabbing from a valid working chef directory?
    """
    And the exit status should be 67

  Scenario: User sees error message if knife.rb is invalid
    Given I have an invalid knife configuration file
    When I run `stab app.node`
    Then the stderr should contain:
    """
    Unable to read organization from knife.rb
    Expected .chef/knife.rb to contain a chef_server_url
    """
    And the exit status should be 67

