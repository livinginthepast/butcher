require 'spec_helper'

describe Butcher::Stab::CLI, 'option parsing' do
  let(:cli) { Butcher::Stab::CLI.new(args) }
  let(:options) { cli.options }

  describe 'defaults' do
    let(:args) { [''] }
    it "sets :force to false" do
      expect(options[:force]).to be_false
    end

    it "sets :verbose to false" do
      expect(options[:verbose]).to be_false
    end

    it "sets :help to false" do
      expect(options[:help]).to be_false
    end
  end

  describe '--force' do
    context 'long' do
      let(:args) { ["--force"] }
      it "sets option :force to true" do
        expect(options[:force]).to be_true
      end
    end

    context "short" do
      let(:args) { ["-f"] }
      it "sets option :force to true" do
        expect(options[:force]).to be_true
      end
    end
  end

  describe '--verbose' do
    context 'long' do
      let(:args) { ["--verbose"] }
      it "sets option :verbose to true" do
        expect(options[:verbose]).to be_true
      end
    end

    context 'short' do
      let(:args) { ["-v"] }
      it "sets option :verbose to true" do
        expect(options[:verbose]).to be_true
      end
    end
  end

  describe '--help' do
    context 'long' do
      let(:args) { ['--help']}
      it "sets :help to true" do
        expect(options[:help]).to be_true
      end
    end

    context 'short' do
      let(:args) { ['-h']}
      it "sets :help to true" do
        expect(options[:help]).to be_true
      end
    end
  end
end

describe Butcher::Stab::CLI, '#usage' do
  it 'returns usage info' do
    expect(Butcher::Stab::CLI.new([]).usage).to eql(<<-END.gsub(/^ {6}/, ''))
      Usage: stab [options] <node name> [ssh options]
        -f    --force       # download new node list even if a cache file exists
        -v    --verbose     # be expressive
        -h    --help        # print this info
    END
  end
end

describe Butcher::Stab::CLI, '#execute!' do
  context 'when :help is true' do
    let(:stdout) { mock() }
    let(:runner) { Butcher::Stab::CLI.new([], mock, stdout) }

    it 'writes usage and exits' do
      runner.options[:help] = true
      stdout.expects(:puts).with(runner.usage)
      runner.execute!
    end
  end

  context "when arguments are empty" do
    it "raises a Usage error" do
      runner = Butcher::Stab::CLI.new([])
      expect { runner.execute! }.to raise_error(Butcher::Stab::UsageError, runner.usage)
    end
  end

  context "node cache file exists" do
    let(:nodes) {
      [
        {:ip => "10.1.1.1", :name => 'app.node', :fqdn => 'app.node.com'},
        {:ip => "10.1.1.2", :name => 'other.node', :fqdn => 'other.node.com'}
      ]
    }
    before { Butcher::Cache.any_instance.stubs(:nodes).returns(nodes) }

    context "stabbing an existing node" do
      it "should open an SSH session to named node" do
        Butcher::Stab::CLI.any_instance.expects(:exec).with("ssh 10.1.1.1").returns(true).once
        Butcher::Stab::CLI.new(['app']).execute!
      end

      it "should ssh to IP based on matched node" do
        Butcher::Stab::CLI.any_instance.expects(:exec).with("ssh 10.1.1.1").never
        Butcher::Stab::CLI.any_instance.expects(:exec).with("ssh 10.1.1.2").returns(true).once
        Butcher::Stab::CLI.new(["other"]).execute!
      end
    end

    context "stabbing a non-existing node" do
      it "should raise an UnmatchedNode error" do
        Butcher::Stab::CLI.any_instance.expects(:exec).never
        expect {
          Butcher::Stab::CLI.new(["nil.node"]).execute!
        }.to raise_error(Butcher::UnmatchedNode)
      end
    end

    context "ambiguous stabbing" do
      it "asks the user which server to connect to" do
        stdin = mock(:gets => "2")
        stdout = mock(:puts => Butcher::Cache.formatted_nodes_for_output(nodes), :write => "\n which server? > ")
        Butcher::Stab::CLI.any_instance.expects(:exec).with("ssh 10.1.1.2").returns(true).once

        Butcher::Stab::CLI.new(["node"], stdin, stdout).execute!
      end
    end
  end

  context "ssh options" do
    mock_cache(:nodes) do
      [{:ip => "10.1.1.1", :name => 'app.node', :fqdn => 'app.node.com'}]
    end

    describe ":login" do
      it "should include login in ssh params" do
        Butcher::Stab::CLI.any_instance.expects(:exec).with("ssh 10.1.1.1 -l username").returns(true).once
        Butcher::Stab::CLI.new(["app", "-l", "username"]).execute!
      end
    end
  end
end
