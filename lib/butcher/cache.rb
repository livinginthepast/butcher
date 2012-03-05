require 'singleton'

class Butcher::Cache
  include Singleton

  CACHE_DIR = "/tmp/butcher"
  NODES_FILENAME = "node.cache"

  def initialize
    FileUtils.mkdir_p(cache_dir)
  end

  def nodes
    hash = {}
    cache_file do |file|
      while file.gets
        node = $_.split(", ")
        hash[node[3]] = [node[1],node[2]]
      end
    end
    hash
  end

  def cache_dir # :nodoc:
    ENV["CACHE_DIR"] || CACHE_DIR
  end

  private

  def nodes_file
    "#{cache_dir}/#{NODES_FILENAME}"
  end

  def create_node_cachefile
    File.open(nodes_file, "w") do |file|
      file.puts %x[knife status]
    end
  end

  def cache_file(&block)
    unless File.exists?(nodes_file)
      create_node_cachefile
    end

    File.open(nodes_file) do |f|
      block.call f
    end
  end
end