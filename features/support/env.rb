$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')

require 'aruba-doubles/cucumber'
require 'aruba/cucumber'
require 'fileutils'
require 'rspec/expectations'
require 'butcher'

Dir["#{File.dirname(__FILE__)}/../../spec/support/**/*.rb"].each { |f| require f unless /_spec\.rb$/.match(f) }
