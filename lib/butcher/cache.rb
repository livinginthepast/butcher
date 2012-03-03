require 'singleton'

class Butcher::Cache
  include Singleton

  CACHE_DIR = "/tmp/butcher"
  NODES_FILENAME = "node.cache"

  def initialize
    FileUtils.mkdir_p(cache_dir)
  end

  def nodes
    unless File.exists?(nodes_file)
      create_node_cachefile
    end

    hash = {}
    file = File.new(nodes_file)
    while file.gets
      node = $_.split(", ")
      hash[node[3]] = [node[1],node[2]]
    end
    hash
  end

  private

  def cache_dir
    CACHE_DIR
  end

  def nodes_file
    "#{cache_dir}/#{NODES_FILENAME}"
  end

  def create_node_cachefile
    File.open(nodes_file, "w") do |file|
      file.puts `knife status`
    end
  end
end