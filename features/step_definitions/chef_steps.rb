Given /I (don't|) ?have a knife configuration file/ do |expectation|
  if expectation == "don't"
    steps %q{
      When I remove the file ".chef/knife.rb"
    }
  else
    steps %q{
      Given a file named ".chef/knife.rb" with:
      """
      chef_server_url "https://opscode.url/organizations/my_organization"
      """
    }
  end
end

Given /I have an invalid knife configuration file/ do
  steps %q{
    Given a file named ".chef/knife.rb" with:
    """
    some invalid content
    """
  }

end

Given /^I have the following chef nodes:$/ do |table|
  create_cache_file("my_organization.cache") do |f|
    table.raw.each do |row|
      f.puts row.join(", ")
    end
  end
end
