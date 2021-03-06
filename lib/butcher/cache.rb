require 'singleton'
require 'chef/config'

class Butcher::Cache
  include Singleton

  KNIFE_FILE = ".chef/knife.rb"

  def nodes(options = {})
    n = []
    cache_file(options) do |file|
      while file.gets
        node = $_.split(", ")
        n << {:ip => node[3], :name => node[1], :fqdn => node[2]}
      end
    end
    n.sort{ |a,b| a[:name] <=> b[:name] }
  end

  def cache_dir # :nodoc:
    "#{ENV["HOME"]}/.butcher/cache"
  end

  def self.formatted_nodes_for_output(nodes)
    i = 0
    nodes.map do |node|
      i += 1
      sprintf("%- 5d %p => %s", i, node[:name], node[:ip])
    end.join("\n")
  end

  def nodes_file
    "#{cache_dir}/#{organization}.cache"
  end

  private

  def organization
    raise Butcher::NoKnifeRB unless(File.exists?(knife_file))
    Chef::Config.from_file(knife_file)
    if m = Chef::Config[:chef_server_url].match(%r[.+/organizations\/([^\/"]+)])
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
      FileUtils.mkdir_p(cache_dir)
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
