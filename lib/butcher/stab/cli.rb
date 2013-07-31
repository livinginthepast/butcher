class Butcher::Stab::CLI
  attr_accessor :argv, :options, :stdin, :stdout, :stderr, :kernel

  def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
    self.argv = argv
    self.stdin = stdin
    self.stdout = stdout
    self.stderr = stderr
    self.kernel = kernel
    self.options = {}
    optparse
  end

  def execute!
    return stdout.puts(usage) if options[:help]
    raise Butcher::Stab::UsageError.new(usage) if node_name.nil?

    ssh_to(matching_node)
  end

  def node_name
    @node_name ||= argv.shift
  end

  def usage
    <<-END.gsub(/^ {6}/, '')
      Usage: stab [options] <node name> [ssh options]
        -f    --force       # download new node list even if a cache file exists
        -v    --verbose     # be expressive
        -h    --help        # print this info
    END
  end

  private

  def matching_node
    @node ||= begin
      nodes = Butcher::Cache.instance.nodes(options).reject do |node|
        ! node[:name].include? self.node_name
      end

      raise(Butcher::UnmatchedNode) if nodes.size == 0

      if nodes.size > 1
        stdout.puts Butcher::Cache.formatted_nodes_for_output(nodes)
        stdout.write "\n which server? > "
        begin
          choice = stdin.gets.chomp.to_i - 1
        rescue Interrupt
          exit
        end
      else
        choice = 0
      end

      nodes[choice]
    end
  end

  def optparse
    options[:force] = !(argv.delete("--force") || argv.delete("-f")).nil?
    options[:verbose] = !(argv.delete("--verbose") || argv.delete("-v")).nil?
    options[:help] = !(argv.delete("--help") || argv.delete("-h")).nil?
  end

  def ssh_to(node)
    STDOUT.sync = true # exec takes over stdout in tests, so sync output
    puts "Connecting to #{node[:name]} at #{node[:ip]}" if options[:verbose]
    exec("ssh #{[node[:ip], argv].flatten.join(' ')}")
  end
end
