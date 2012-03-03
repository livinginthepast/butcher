module TestCache
  def self.reset
    cleanup
    setup
  end

  def self.setup
    stub_cache
    FileUtils.mkdir_p("tmp/spec")
  end

  def self.cleanup
    FileUtils.rm_rf("tmp")
  end

  def self.cache_dir
    File.expand_path("tmp/spec")
  end

  def self.stub_cache
    Butcher::Cache.any_instance.stubs(:cache_dir).returns(cache_dir)
  end
end

def create_cache_file(filename)
  before do
    File.open("#{TestCache.cache_dir}/#{filename}", "w") do |file|
      yield file
    end
  end
end

def mock_cache(type, &block)
  before do
    Butcher::Cache.any_instance.stubs(type).returns(block.call)
  end
end
