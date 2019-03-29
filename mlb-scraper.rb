require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'pry-byebug'
require 'typhoeus'

DESIRED_MARGIN = 0.2

price_ranges = []

300.times do |number|
  sell_price = number + 100
 # profit = DESIRED_MARGIN * sell_price
  profit = 150
  buy_price = ((profit + sell_price) / 0.9).floor
  price_ranges << [buy_price, sell_price]
end

file = File.open('result.html', 'a')
file.puts "<html><head></head><body><table>"
html = ''
names = []

file_special = File.open('special.html', 'a')
special_html = ''

hydra = Typhoeus::Hydra.new(max_concurrency: 50)

price_ranges.each do |range|
  url = "https://mlb19.theshownation.com/community_market?min_best_sell_price=#{range[0]}&max_best_sell_price=50000&max_best_buy_price=#{range[1]}&series_id=1337"
  request = Typhoeus::Request.new(url)

  request.on_complete do |response|
    if response.success?
      p url
      trs = Nokogiri::HTML(response.body).css('.items-results-table tbody tr')
      trs.each do |tr|
        name = tr.children[3].children[1].children[0].text.gsub("\n", "")
        html_string = tr.to_html.gsub("/community_market", "https://mlb19.theshownation.com/community_market")
        if !html_string.empty? && !names.include?(name)
          names << name
          puts html_string
          html << html_string
        end
      end
    else
      p "** FAILED: #{url}"
    end
  end
  hydra.queue(request)
end
hydra.run
file.puts html
file.puts "</table></body></html>"
file.close


