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
    raise(Butcher::UnmatchedNode) if nodes.size == 0
    raise(Butcher::AmbiguousNode, Butcher::Cache.format_nodes_for_stderr(nodes)) if nodes.size > 1
    nodes.keys.first
  end

  def nodes
    @nodes ||= Butcher::Cache.instance.nodes(options).reject do |k, v|
      ! String(v).include? self.node_name
    end
  end

  def optparse
    options[:force] = !(argv.delete("--force") || argv.delete("-f")).nil?
    options[:verbose] = !(argv.delete("--verbose") || argv.delete("-v")).nil?
    options[:help] = !(argv.delete("--help") || argv.delete("-h")).nil?
  end

  def ssh_to(ip)
    STDOUT.sync = true # exec takes over stdout in tests, so sync output
    puts "Connecting to #{node_name} at #{ip}" if options[:verbose]
    exec("ssh #{[ip, argv].flatten.join(' ')}")
  end
end
