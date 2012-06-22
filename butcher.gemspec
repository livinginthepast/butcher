# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "butcher/version"

Gem::Specification.new do |s|
  s.name        = "butcher"
  s.version     = Butcher::VERSION
  s.authors     = ["ModCloth", "Eric Saxby"]
  s.email       = %W(git@modcloth.com)
  s.homepage    = "https://github.com/modcloth/butcher"
  s.summary     = %q{All the things to make a chef}
  s.description = %q{Chef is a tool for managing server automation. A good butcher makes for a good chef.}

  s.rubyforge_project = "butcher"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %W(lib)

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec", "> 2"
  s.add_development_dependency "aruba"
  s.add_development_dependency "aruba-doubles"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "guard-cucumber"
  s.add_development_dependency "mocha"
  # s.add_runtime_dependency "x"
  s.add_runtime_dependency "chef"
end
