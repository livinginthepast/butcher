# Butcher

Butcher is a set of command line tools intended to ease the use of Chef with a managed
Opscode account.

## Commands

The following commands are currently available. All commands should be run from the top
level of a chef directory.

### Stab

SSH into a node based on a grep of the node name.

        Usage: stab [options] node_name
          -h, --help             # prints usage
          -c, --cache-dir DIR    # saves node list here (default: /tmp/butcher)
          -f, --force            # download new node list even if a cache file exists
          -v, --verbose          # be expressive

Node name is loosely matched against name attributes given to nodes in chef. If multiple
nodes match a given string, a Butcher::AmbiguousNode error is thrown and the program exits.

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

