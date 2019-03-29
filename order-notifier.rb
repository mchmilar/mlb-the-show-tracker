require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'byebug'
require 'pry-byebug'

agent = Mechanize.new

page = agent.get('https://mlb19.theshownation.com/community_market?page=1&type_id=0&series_id=1337')
pagination = page.search('.pagination')

number_of_pages = pagination.children[pagination.children.size - 2].children.text.to_i

total = 0

number_of_pages.times do |number|
  page_number = number + 1
  page = agent.get("https://mlb19.theshownation.com/community_market?page=#{page_number}&type_id=0&series_id=1337")
  results_table = page.search('.items-results-table tbody')
  results_table.children.each do |child|
    next if child.is_a?(Nokogiri::XML::Text)
    name = child.elements[1].children[1].children[0].text.gsub("\n", "")
    price = child.elements[4].children[2].text.gsub("\n", "").to_i
    puts "#{name}\t\t#{price}"
    total = total + price
  end
end

puts "Total price: #{total}"



