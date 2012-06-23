require 'singleton'

class Butcher::Cache
  include Singleton

  CACHE_DIR = "#{ENV["HOME"]}/.butcher/cache"
  KNIFE_FILE = ".chef/knife.rb"

  def initialize
    FileUtils.mkdir_p(cache_dir)
  end

  def nodes(options = {})
    hash = {}
    cache_file(options) do |file|
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

  def self.format_nodes_for_stderr(nodes)
    nodes.map do |key, value|
      %Q{#{value.inspect} => #{key}}
    end.sort.join("\n")
  end

  def nodes_file
    "#{cache_dir}/#{organization}.cache"
  end

  private

  def organization
    raise Butcher::NoKnifeRB unless(File.exists?(knife_file))
    if m = File.read(knife_file).match(/chef_server_url\s+".+organizations\/([^\/"]+)"/)
      m[1]
    else
      raise Butcher::NoKnifeOrganization
    end
  end

  def knife_file
    File.expand_path(KNIFE_FILE, ENV["PWD"])
  end

  def create_node_cachefile
    with_safe_paths do
      File.open(nodes_file, "w") do |file|
        file.puts %x[knife status]
      end
    end
  end

  def cache_file(options, &block)
    if options[:force] || !File.exists?(nodes_file)
      puts "Creating cache file of nodes" if options[:verbose]
      create_node_cachefile
    end

    File.open(nodes_file) do |f|
      block.call f
    end
  end

  # RVM rewrites paths to ensure that it is first. This makes it impossible
  # to use aruba in cucumber with any gem executables.
  def with_safe_paths
    original_path = (ENV["PATH"] || '').split(::File::PATH_SEPARATOR)
    aruba_path = original_path.select { |x| x =~ /\/tmp\/d\d{8}-\d+-.+/}
    ENV['PATH'] = (aruba_path | original_path).join(::File::PATH_SEPARATOR)
    yield
  ensure
    ENV["PATH"] = original_path.join(::File::PATH_SEPARATOR)
  end
end
