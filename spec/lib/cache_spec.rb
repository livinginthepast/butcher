require 'spec_helper'

describe Butcher::Cache, "initialization" do
  ## singletons do not reset after initialization, so we run tests against clones

  class CacheSingletonForEnv < Butcher::Cache; end
  it "should accept cache_dir from env" do
    ENV["CACHE_DIR"] = "tmp/cache_from_options"
    test(?d, "tmp/cache_from_options").should be_false
    CacheSingletonForEnv.instance
    ENV["CACHE_DIR"] = nil
    test(?d, "tmp/cache_from_options").should be_true
  end

  class CacheSingleton < Butcher::Cache; end
  it "should create cache directory" do
    CacheSingleton.any_instance.stubs(:cache_dir).returns("tmp/cache_stub")
    test(?d, "tmp/cache_stub").should be_false
    CacheSingleton.instance
    test(?d, "tmp/cache_stub").should be_true
  end
end

describe Butcher::Cache, "#nodes_file" do
  context "cannot find knife.rb" do
    it "should raise an error" do
      File.expects(:exists?).with("#{ENV["PWD"]}/.chef/knife.rb").returns(false)
      lambda {
        Butcher::Cache.instance.nodes_file
      }.should raise_error(Butcher::NoKnifeRB)
    end
  end

  context "sees a knife.rb" do
    before { File.expects(:exists?).with("#{ENV["PWD"]}/.chef/knife.rb").returns(true) }

    context "without chef_server_url" do
      it "should raise an error" do
        File.expects(:read).with("#{ENV["PWD"]}/.chef/knife.rb").returns(
          'some random content'
        )
        lambda {
          Butcher::Cache.instance.nodes_file
        }.should raise_error(Butcher::NoKnifeOrganization)
      end
    end

    context "with chef_server_url" do
      let(:expected_file) { "#{Butcher::TestCache.cache_dir}/my_organization.cache" }

      it "should set filename based on chef_server_url" do
        File.expects(:read).with("#{ENV["PWD"]}/.chef/knife.rb").returns(
          'chef_server_url "https://api.opscode.com/organizations/my_organization"'
        )
        Butcher::Cache.instance.nodes_file.should == expected_file
      end
    end
  end
end

describe Butcher::Cache, "#nodes" do
  let(:cache_file) { "#{Butcher::TestCache.cache_dir}/ops_org.cache" }
  before { Butcher::Cache.any_instance.stubs(:nodes_file).returns(cache_file) }

  context "cache file does not exist" do
    before do
      File.exists?(cache_file).should be_false
      Butcher::Cache.any_instance.stubs(:`).with("knife status").returns("knife return codes")
    end

    it "should not raise an error" do
      lambda { Butcher::Cache.instance.nodes }.should_not raise_error
    end

    it "should create a node list from knife" do
      Butcher::Cache.instance.nodes
      File.exists?(cache_file).should be_true
    end
  end

  context "cache file exists" do
    create_cache_file("ops_org.cache") do |f|
      f.puts "5 minutes ago, app.node, app.domain.com, 192.168.1.1, some os"
      f.puts "1 minute ago, other.node, other.domain.com, 192.168.1.2, some os"
    end

    it "maps file to hash" do
      Butcher::Cache.instance.nodes.should == {
        "192.168.1.1" => %W(app.node app.domain.com),
        "192.168.1.2" => %W(other.node other.domain.com)
      }
    end
  end
end
