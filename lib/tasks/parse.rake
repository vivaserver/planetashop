require 'open-uri'
require 'hpricot'
require 'iconv'

ML_USER  = 'ELVENGADOR'
ML_PASS  = 'RUxWRU5HQURPUlZFTkdBRE9S'
ML_CATEG = '1734'
ML_AFFL_SITE   = '332851'
ML_SEARCH_WORD = 'linux'

namespace :parse do
  desc 'xML parsing with Hpricot'
  task :xml => [ :migrate ] do
    Country.find(:all).each do |country|
      puts "parsing #{country.title}"
      xml   = Hpricot.XML(open("#{country.url_base}jm/searchXml?as_categ_id=#{ML_CATEG}&user=#{ML_USER}&pwd=#{ML_PASS}"))
      items = ((xml/:items)/:item)
      # remember last item created for later table flush
      if country.items_count > 0
        last = country.items.sort_by { |i| i.created_at }.last
        puts "previous last item created at #{last.created_at}"
      end
      unless items.size > 0
        xml   = Hpricot.XML(open("#{country.url_base}jm/searchXml?as_word=#{ML_SEARCH_WORD}&user=#{ML_USER}&pwd=#{ML_PASS}"))
        items = ((xml/:items)/:item)
      end
      items.each do |e|
        @item = Item.new
        @item.country_id = country.id
        @item.number = e['id'].to_i
        # thanks to http://railstips.org/2006/12/9/parsing-xml-with-hpricot
        ['title','link','image_url','seller_type','auction_type','mpago','currency','price','bids','hot','hits','auct_end','listing_features','zones','feedback','condition'].each do |i|
          case i
            # production db is now mysql with utf8_general_ci encoding, so conversion to/from iso-8859-1 is no longer necessary
            # (also, all xml parsing in ruby is utf-8)
            # when 'title'
            #   title = e.at(i).inner_text.strip
            #   title = Iconv.new('utf-8','iso-8859-1').iconv(title)
            #   @item.title = title
            when 'link'
              @item.link = e.at(i).inner_text.strip.gsub('XXX',ML_AFFL_SITE)
            when 'image_url'
              @item.image_url = e.at(i).inner_text.strip.gsub('&amp;','&')
            when 'auct_end'
              if e.at(i).inner_text.strip =~ /.+ (\d{2}) (.+) (\d{4}) (\d{2}):(\d{2}):(\d{2}) .+/
                case $2.downcase
                  when 'jan' 
                    mm = '01'
                  when 'feb' 
                    mm = '02'
                  when 'mar' 
                    mm = '03'
                  when 'apr' 
                    mm = '04'
                  when 'may' 
                    mm = '05'
                  when 'jun' 
                    mm = '06'
                  when 'jul' 
                    mm = '07'
                  when 'aug' 
                    mm = '08'
                  when 'set' 
                    mm = '09'
                  when 'sep' 
                    mm = '09'
                  when 'oct' 
                    mm = '10'
                  when 'nov' 
                    mm = '11'
                  when 'dec' 
                    mm = '12'
                end
                @item.auct_end = "#{$3}-#{mm}-#{$1} #{$4}:#{$5}:#{$6}"
              end
            when 'listing_features'
              @item.photo     = (e.at('photo').inner_text.strip     == 'Y' ? 1 : 0)
              @item.highlight = (e.at('highlight').inner_text.strip == 'Y' ? 1 : 0)
              @item.bold      = (e.at('bold').inner_text.strip      == 'Y' ? 1 : 0)
            when 'feedback'
              @item.points      = e.at('points').inner_text.strip
              @item.composition = e.at('composition').inner_text.strip
            else
              # cool: send attribute assignment to @item object
              @item.send(i+'=',e.at(i).inner_text.strip)
          end
        end
        puts "Item #{@item.number} saved for #{@item.country.title}" if @item.save_with_validation(false)
      end
      # destroy old items keeping just the newly created
      # we use 'destroy' instead of 'delete' to keep track of :stories_count in Country model
      Item.destroy_all("country_id = '#{country.id}' and created_at <= '#{last.created_at.strftime('%Y-%m-%d %H:%M:%S')}'") if last
      # also clear the Country cache
      clear_country_cache(country.name)
    end
  end
  
  desc 'clears the cache files by country name'
  task :clear_cache do
    unless ENV.include?('country')
      puts "clearing all countries cache"
      Country.find(:all).each { |country| clear_country_cache(country.name) }
    else
      puts "clearing #{ENV['country']} cache"
      clear_country_cache(ENV['country'])
    end
  end
  
  def clear_country_cache(country)
    if File.directory?("#{RAILS_ROOT}/public/cache/#{country}")
      # delete all html files in country directory
      Dir.chdir("#{RAILS_ROOT}/public/cache/#{country}") { |d|
        Dir.glob('*.html') { |f| File.delete(f) }
      }
      # delete country directory itself
      Dir.delete("#{RAILS_ROOT}/public/cache/#{country}")
    end
    # delete {country}.html cache file 
    if country == 'argentina'
      File.delete("#{RAILS_ROOT}/public/cache/index.html") if File.file?("#{RAILS_ROOT}/public/cache/index.html")
    else
      File.delete("#{RAILS_ROOT}/public/cache/#{country}.html") if  File.file?("#{RAILS_ROOT}/public/cache/#{country}.html")
    end
  end
end
