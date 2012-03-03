require 'spec_helper'

describe Butcher::Stab::CLI do

  context "arguments are nil" do
    it "should return empty string" do
      Butcher::Stab::CLI.new.run(nil).should == ""
    end
  end

  context "node cache file exists" do
    mock_cache(:nodes) do
      {"10.1.1.1" => %W(app.node app.node.com), "10.1.1.2" => %W(other.node other.node.com)}
    end

    context "stabbing an existing node" do
      it "should open an SSH session to named node" do
        Butcher::Stab::CLI.any_instance.expects(:exec).with("ssh 10.1.1.1").returns(true).once
        Butcher::Stab::CLI.new.run("app")
      end

      it "should ssh to IP based on matched node" do
        Butcher::Stab::CLI.any_instance.expects(:exec).with("ssh 10.1.1.1").never
        Butcher::Stab::CLI.any_instance.expects(:exec).with("ssh 10.1.1.2").returns(true).once
        Butcher::Stab::CLI.new.run("other")
      end
    end

    context "stabbing a non-existing node" do
      it "should raise an UnmatchedNode error" do
        Butcher::Stab::CLI.any_instance.expects(:exec).never
        lambda {
          Butcher::Stab::CLI.new.run("nil.node")
        }.should raise_error(Butcher::UnmatchedNode)
      end
    end

    context "ambiguous stabbing" do
      it "should raise an AmbiguousNode error" do
        Butcher::Stab::CLI.any_instance.expects(:exec).never
        lambda {
          Butcher::Stab::CLI.new.run("node")
        }.should raise_error(Butcher::AmbiguousNode)
      end
    end
  end
end