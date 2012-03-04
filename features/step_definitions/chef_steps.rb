Given /^I have the following chef nodes:$/ do |table|
  create_cache_file("nodes.cache") do |f|
    table.raw.each do |row|
      f.puts row.join(", ")
    end
  end
end