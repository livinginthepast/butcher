class Butcher::Stab::CLI
  attr_accessor :node_matcher
  attr_accessor :options

  def run(arguments, options = {})
    self.options = options
    self.node_matcher = Array(arguments).first
    return "" if node_matcher.nil?

    connect(matching_node)
  end

  private

  def connect(ip)
    STDOUT.sync = true # exec takes over stdout in tests, so sync output
    puts "Connecting to #{node_matcher} at #{ip}" if options[:verbose]
    exec("ssh #{ip}")
  end

  def matching_node
    nodes = Butcher::Cache.instance.nodes(options).select do |k, v|
      String(v).include? self.node_matcher
    end

    raise(Butcher::UnmatchedNode) if nodes.size == 0
    raise(Butcher::AmbiguousNode, nodes.values.flatten.uniq) if nodes.size > 1
    nodes.keys.first
  end
end