Given /I (don't|) ?have a knife configuration file/ do |expectation|
  if expectation == "don't"
    steps %Q{
      When I remove the file "#{ENV["PWD"]}/.chef/knife.rb"
    }
  else
    steps %Q{
      Given a file named "#{ENV["PWD"]}/.chef/knife.rb" with:
      """
      chef_server_url "https://opscode.url/organizations/my_organization"
      validation_key  "my_organization.pem"
      validation_client_name "my_organization-validator"
      """
    }
  end
end

Given /I have an invalid knife configuration file/ do
  steps %Q{
    Given a file named "#{ENV["PWD"]}/.chef/knife.rb" with:
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
