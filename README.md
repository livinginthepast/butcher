# Butcher

Butcher is a set of command line tools intended to ease the use of Chef with a managed
Opscode account.

### Installation

        gem install "butcher"

Or stick this in your Gemfile

       gem "butcher"
       #  or
       gem "butcher", "~>0.0.1"

## Commands

The following commands are currently available. All commands should be run from the top
level of a chef directory.

### Stab

SSH into a node based on a grep of the node name.

        Usage: stab [options] node_name
          -c, --cache-dir DIR    # saves node list here (default: ~/.butcher/cache)
          -f, --force            # download new node list even if a cache file exists
          -h, --help             # prints usage
          -l, --login LOGIN      # ssh with specified username
          -v, --verbose          # be expressive

Node name is loosely matched against name attributes given to nodes in chef. If multiple
nodes match a given string, a Butcher::AmbiguousNode error is thrown and the program exits.

        > knife status
        1 hours ago, app.node, app.domain.com, 1.1.1.1, solaris2 5.11.
        5 minutes ago, other.node, other.domain.com, 1.1.1.2, solaris2 5.11.

        > stab something
        Unable to find node "something"

        > stab node
        Multiple nodes match "node"
        ["app.node", "app.domain.com"] => 1.1.1.1
        ["other.node", "other.domain.com"] => 1.1.1.2

Nodes are cached in a file named after your organization in Opscode. Stab discovers this
by looking at the chef_server_url in your knife.rb. For this reason, stab can only be run
from the top level of a chef repo.


## Build Status

[![Build status](https://secure.travis-ci.org/modcloth/butcher.png)](http://travis-ci.org/modcloth/butcher)


## License

Copyright 2012 ModCloth

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

