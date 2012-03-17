class Butcher::Stab::CLI
  attr_accessor :node_matcher
  attr_accessor :options

  def run(arguments, options = {})
    self.options = options
    self.node_matcher = Array(arguments).first
    return "" if node_matcher.nil?

    ssh_to(matching_node)
  end

  private

  def ssh_to(ip)
    STDOUT.sync = true # exec takes over stdout in tests, so sync output
    puts "Connecting to #{node_matcher} at #{ip}" if options[:verbose]
    exec("ssh #{ip}#{ssh_options}")
  end

  def matching_node
    raise(Butcher::UnmatchedNode) if nodes.size == 0
    raise(Butcher::AmbiguousNode, Butcher::Cache.format_nodes_for_stderr(nodes)) if nodes.size > 1
    nodes.keys.first
  end

  def ssh_options
    if options[:login]
      " -l #{options[:login]}"
    end
  end

  def nodes
    @nodes ||= Butcher::Cache.instance.nodes(options).reject do |k, v|
      ! String(v).include? self.node_matcher
    end
  end
end
