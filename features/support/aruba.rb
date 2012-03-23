Before do
  @dirs = ["."]
  @aruba_timeout_seconds = 8
  set_env("PWD", "#{Butcher::TestCache::PWD}/tmp")
end
