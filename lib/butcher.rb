require "butcher/version"
require "fileutils"

module Butcher
  class UnmatchedNode       < Exception;end
  class AmbiguousNode       < Exception;end
  class NoKnifeRB           < Exception;end
  class NoKnifeOrganization < Exception;end
end

require 'butcher/stab'
require 'butcher/stab/cli'
require 'butcher/cache'
