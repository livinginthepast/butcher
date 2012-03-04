# = Butcher::TestCache
#
# Providing helpers for testing Butcher using RSpec and Cucumber.
#
# Author::    Eric Saxby (mailto:e.saxby@modcloth.com)
# Copyright:: Copyright (c) 2012 ModCloth
# License::   Distributes under the same terms as Ruby
#
# == RSpec Usage:
#
#    RSpec.configure do |config|
#      Butcher::TestCache.setup_rspec(config)
#    end
#
# == Cucumber Usage:
#
#    require 'butcher'
#    Before { Butcher::TestCache.reset }
#    After { Butcher::TestCache.cleanup }
#    World(Butcher::TestCache::TestHelpers)
#
module Butcher::TestCache
  def self.setup_rspec(config)
    config.before(:each) do
      Butcher::TestCache.reset
    end

    config.after(:suite) do
      Butcher::TestCache.cleanup
    end

    config.extend(RSpecExampleHelpers)
    config.include(TestHelpers)
  end

  def self.reset # :nodoc:
    cleanup
    setup
  end

  def self.cleanup # :nodoc:
    FileUtils.rm_rf("tmp")
  end

  def self.cache_dir # :nodoc:
    File.expand_path("tmp/test")
  end

  private

  def self.setup
    stub_cache
    FileUtils.mkdir_p("tmp/test")
  end

  def self.stub_cache
    Butcher::Cache.any_instance.stubs(:cache_dir).returns(cache_dir)
  end

  public

  # == RSpecExampleHelpers
  #
  # RSpec helpers that can be used in the scope of an example group or a describe block.
  # These cannot be called from within tests themselves.
  module RSpecExampleHelpers

    # Creates a file that Butcher::Cache can parse before every test in the current context.
    # Used for testing the Cache class itself.
    #
    # example:
    #    create_cache_file("nodes.cache") do |f|
    #      f.puts "1 hour ago, node.name, node.domain, 192.168.1.1, os name"
    #    end
    #
    def create_cache_file(filename, &block)
      before do
        create_cache_file(filename, &block)
      end
    end

    # Mock out responses on Butcher::Cache for every test in the current context.
    # Used in classes where you want to test against expected output from Cache.
    #
    # example:
    #    mock_cache(:nodes) do
    #      {"192.168.1.1" => ["node.name","node.domain"]}
    #    end
    #
    def mock_cache(type, &block)
      before do
        Butcher::Cache.any_instance.stubs(type).returns(block.call)
      end
    end
  end

  # == TestHelpers
  #
  # RSpec helpers that can be used within tests
  module TestHelpers

    # Creates a file that Butcher::Cache can parse
    def create_cache_file(filename)
      File.open("#{Butcher::TestCache.cache_dir}/#{filename}", "w") do |file|
        yield file
      end
    end
  end
end

