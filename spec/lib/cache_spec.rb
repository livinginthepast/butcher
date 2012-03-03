require 'spec_helper'

describe Butcher::Cache, "initialization" do
  before do
    @cache_class = Butcher::Cache.clone
    @cache_class.any_instance.stubs(:cache_dir).returns("tmp/cache_stub")
  end

  it "should create cache directory" do
    test(?d, "tmp/cache_stub").should be_false
    Butcher::Cache.instance
    test(?d, "tmp/cache_stub").should be_true
  end
end

describe Butcher::Cache, "#nodes" do
  context "cache file does not exist" do
    let(:cache_file) { "#{TestCache.cache_dir}/node.cache" }
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
    create_cache_file("node.cache") do |f|
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