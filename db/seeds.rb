
site = Site.create!(name: "Publisher 1")

1000.times do |i|
  site.pages.create!(url: "http://httpbin/html?page=#{i+1}")
end
