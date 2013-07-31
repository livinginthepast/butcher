# Butcher

[![Build status](https://secure.travis-ci.org/livinginthepast/butcher.png)](http://travis-ci.org/livinginthepast/butcher)

Butcher is a set of command line tools intended to ease the use of Chef with a managed
Opscode account.

### Installation

```ruby
gem install "butcher"
```

Or stick this in your Gemfile

```ruby
gem "butcher"
#  or
gem "butcher", "~>1.0.0"
```

## Commands

The following commands are currently available. All commands should be run from the top
level of a chef directory.

### Stab

SSH into a node based on a grep of the node name.

```bash
Usage: stab [options] <node name> [ssh options]
  -f, --force            # download new node list even if a cache file exists
  -h, --help             # prints usage
  -v, --verbose          # be expressive
```

Node name is loosely matched against name attributes given to nodes in chef. If multiple
nodes match a given string, stab will ask for clarification. Enter the
number of the host to connect:

```bash
> knife status
1 hours ago, app.node, app.domain.com, 1.1.1.1, solaris2 5.11.
5 minutes ago, other.node, other.domain.com, 1.1.1.2, solaris2 5.11.

> stab something
Unable to find node "something"

> stab node
 1   "app.node" => 1.1.1.1
 2   "other.node" => 1.1.1.2

 which server? >
```

Nodes are cached in a file named after your organization in Opscode. Stab discovers this
by looking at the chef_server_url in your knife.rb. For this reason, stab can only be run
from the top level of a chef repo.


## License

Copyright (c) 2012 Eric Saxby

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
