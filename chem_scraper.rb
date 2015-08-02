require 'rubygems'
require 'nokogiri'
require 'open-uri'
require './compound_class'

puts "Please enter a CAS Number:"
input = gets.to_s.chomp

#input = "104-94-9"

cas = Compound.new(input)

QUERY_URL = "http://www.sigmaaldrich.com/catalog/search?term=#{cas.cas_num}&interface=CAS%20No.&N=0+&mode=partialmax&lang=en&region=US&focus=product"

ALDRICH_BASE_URL = "http://www.sigmaaldrich.com"

HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

search_page = Nokogiri::HTML(open(QUERY_URL))

chem_url = search_page.css('li.productNumberValue a')[0]['href']

sleep 1

chem_page = Nokogiri::HTML(open(ALDRICH_BASE_URL + chem_url))

properties_table = chem_page.css('div#productDetailProperties table tbody')

trs = properties_table.css('tr').map
trs.each do |tr|
	temp = tr.css('td.lft').to_s
	if temp.include?("\tbp\n")
		boiling_point = tr.css('td.rgt').to_s
		cas.bp = boiling_point.match(/[\d-]+/).to_s
	elsif temp.include?("\tmp\n")
		melting_point = tr.css('td.rgt').to_s
		cas.mp = melting_point.match(/[\d-]+/).to_s
	elsif temp.include?("\tdensity\n")
		rho = tr.css('td.rgt').to_s
		cas.density = rho.match(/[\d.]+/).to_s
	end
end

puts "CAS Number: " + cas.cas_num
puts "Melting Point: " + cas.mp + " °C" if cas.mp != nil
puts "Boiling Point: " + cas.bp + " °C" if cas.bp != nil
puts "Density: " + cas.density + " g/mL" if cas.density != nil
			