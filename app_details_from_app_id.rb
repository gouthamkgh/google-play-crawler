# 1. Given a set of app IDs, we are scraping the Play Store for app details
# 2. Also, we are just reading dev ids from a file and appending them with the app details
# 3. We have the set of current_app_ids and current_dev_ids from a simple script to parse our App_and_dev_ids file (obtained from get_all_app_ids.rb)
# The dev and app ids are obtained from the file get_all_app_ids.rb

#!/usr/bin/ruby
require 'rubygems'
require 'mechanize'

agent = Mechanize.new

app_ids = File.open('curr_app_ids').readlines
app_ids.each do |appid|
        begin
                appid.chomp!.gsub!(' ','+')
        rescue
                puts "Invalid sequence in ID"
        end
end

devids_file = File.open('curr_dev_ids').readlines
dev_ids = []
devids_file.each do |x|
  dev_ids << x.strip
end
count = 0

google_play_base_url = "https://play.google.com/store/apps/details?id="

puts "Array size - #{app_ids.size}"+"\n"

f3 = File.open('Invalid_app_ids','w')

if (!app_ids.empty?)
  f = File.open('App_and_dev_details.txt', 'w')
  app_ids.each do |appid|
    begin
    page = agent.get(google_play_base_url+appid)
    sidebar = page.parser.css("div.content")
    totalDownloads = sidebar[2].children.to_s.split("-").last.gsub(',','').to_i

    reviews = page.parser.css("span.reviews-num")
    ratingCount = reviews[0].children.to_s.gsub(",",'').to_i

    score = page.parser.css("div.score")
    averageRating = score[0].children.to_s

    category = page.parser.css("a.category")
    appCategory = category[0].children.to_s.split('</span>')[0].split('>').last

    emailbar = page.parser.css("a.dev-link")
    num_emails = emailbar.size
    if(num_emails < 3)
      devEmail = emailbar[num_emails-1].attributes["href"].value.split(":").last
    elsif(num_emails == 3)
      devEmail = emailbar[1].attributes["href"].value.split(":").last
    end

    line = "Developer_id - #{dev_ids[count]}, App - #{appid}, rating - #{averageRating}, rating_count - #{ratingCount}, installs - #{totalDownloads}, category - #{appCategory}, developer_email - #{devEmail}"+"\n"
    puts "#{line}"
    sleep(4)
    f.write(line)
    count += 1
    rescue
      puts "Invaid app ID. Hard luck mate!"
      pkgID_invalid = "#{appid}\n"
      f3.write(pkgID_invalid)
      count += 1
    end
  end
 f.close
 f3.close 
else
  puts "Query output execution issue - could be connection issue or output nil issue"
end
