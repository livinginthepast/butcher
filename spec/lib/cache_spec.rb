require 'spec_helper'

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
    before {
      File.expects(:exists?).with("#{ENV["PWD"]}/.chef/knife.rb").returns(true)
      Chef::Config.expects(:from_file).with("#{ENV["PWD"]}/.chef/knife.rb").returns(true)
    }

    context "without chef_server_url" do
      before {
        Chef::Config.expects(:[]).with(:chef_server_url).returns("random content")
      }

      it "should raise an error" do
        lambda {
          Butcher::Cache.instance.nodes_file
        }.should raise_error(Butcher::NoKnifeOrganization)
      end
    end

    context "with chef_server_url" do
      let(:expected_file) { "#{Butcher::TestCache.cache_dir}/my_organization.cache" }
      before {
        Chef::Config.expects(:[]).with(:chef_server_url).returns("https://api.opscode.com/organizations/my_organization")
      }

      it "should set filename based on chef_server_url" do
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
      Butcher::Cache.instance.nodes.should == [
        {:ip => "192.168.1.1", :name => "app.node", :fqdn => "app.domain.com"},
        {:ip => "192.168.1.2", :name => "other.node", :fqdn => "other.domain.com"}
      ]
    end
  end
end

describe Butcher::Cache, '.formatted_nodes_for_output' do
  it 'returns node info in a numbered list' do
    nodes = [
      {:ip => "123.4.5.6", :name => "node1", :fqdn => "node1.prod"},
      {:ip => "901.4.5.6", :name => "node2", :fqdn => "node2.prod"}
    ]
    expect(Butcher::Cache.formatted_nodes_for_output(nodes)).
      to eql(%Q{ 1    "node1" => 123.4.5.6\n 2    "node2" => 901.4.5.6})
  end
end
