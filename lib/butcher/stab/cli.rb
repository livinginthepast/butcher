class Butcher::Stab::CLI
  attr_accessor :node_matcher

  def run(arguments)
    return "" if arguments.nil?

    self.node_matcher = Array(arguments).first
    exec("ssh #{matching_node}")
  end

  private

  def matching_node
    nodes = Butcher::Cache.instance.nodes.select do |k, v|
      String(v).include? self.node_matcher
    end

    raise(Butcher::UnmatchedNode) if nodes.size == 0
    raise(Butcher::AmbiguousNode) if nodes.size > 1
    nodes.keys.first
  end
end