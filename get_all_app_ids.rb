# We are trying to achieve three things here
# 1. From a file that contains developer IDs, we are trying to scrape play store and fetch all app ids for that developer
# 2. Developer ID, Number of apps by that developer - pair
# 3. App-id | Dev-id list in a file

#!/usr/bin/ruby
require 'rubygems'
require 'mechanize'

agent = Mechanize.new

# Read input from file to get developer IDs
developer_ids = File.open('Developer_IDs.txt').readlines
developer_ids.each do |devID|
	begin
		devID.chomp!.gsub!(' ','+')
	rescue
		puts "Invalid sequence in ID"
	end
end

baseurl = "https://play.google.com/store/apps/developer?id="
all_app_ids = []
ids_array = []
current_count = 0
previous_count = 0
f = File.open('Developer_app_counts_and_ids','w')      # Write into this file developer id and the app counts

if (!developer_ids.empty?)
	developer_ids.each do |x|
		begin
			previous_count = current_count
			url = baseurl+x
			puts "URL - #{url}"
			page = agent.get(url)
			cards = page.parser.css("a.card-click-target")
			cards.each do |card|
				list_of_ids = card.attributes["href"].value.split('=').last
				devs_array = x
				ids_array << [list_of_ids, devs_array]
			end
		rescue
			puts "Invalid ID"
		end
			ids_array.uniq!
			current_count = ids_array.length
			count_by_developer = current_count - previous_count
			line = "Developer - #{x} Count - #{count_by_developer}\n"
			puts "#{line}"
			f.write(line)
		end
end

f.close
ids_array.sort!

# Write all the app ids into a file to iterate over them
all_app_ids_file = File.open('App_and_dev_ids','w')
ids_array.each do |appid, devid|
	line = "#{appid}|#{devid}\n"
	all_app_ids_file.write(line)
end
all_app_ids_file.close
