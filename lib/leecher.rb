class Leecher
  require 'uri'
  require 'net/http'

  def initialize
    @headers = { 'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)' }
  end

  #
  # leeches one target at a time
  #
  def leech(target=nil,opt=nil,limit=nil)
    if not target
      # no target site provided, usage must be something like "runleecher.rb [ sitename [update|save] [news_limit] ]"
      puts "(Fatal Error) No target site privided\n"
    else
      puts "Leeching #{target.title} ...\n#{target.url_target}\n\n"
      #
      url   = Regexp.new(target.regexp_url)
      date  = Regexp.new(target.regexp_date) if target.regexp_date
      time  = Regexp.new(target.regexp_time) if target.regexp_time
      title = Regexp.new(target.regexp_title)
      intro = Regexp.new(target.regexp_intro)
      #
      if res = retrieve_url(target.url_target)
        # url, title & intro are a must for leeched articles
        urls   = res.body.scan(url)
        titles = res.body.scan(title)
        intros = res.body.scan(intro)
        dates  = res.body.scan(date) if date
        times  = res.body.scan(time) if time
        #
        if urls.empty?
          puts "\tError: No match at all. Time to update RexExps?\n"
        elsif urls.size == titles.size && titles.size == intros.size
          # update 'limit' stories: delete first 'limit' stories before inserting new
          if opt == 'update'
            if target.limit
              if target.limit == 0
                target.stories.destroy_all
              else
                target.stories.find(:all, :limit => target.limit).each { |obj| obj.destroy }
              end
            elsif limit
              target.stories.find(:all, :limit => limit).each { |obj| obj.destroy }
            end
          end
          # urls, titles & intros #'s match, process
          urls.each_with_index do |uri,i|
            break if (limit && limit.to_i==i) || (target.limit && target.limit!=0 && target.limit==i)
            #
            uri = strip_html(uri.to_s.strip)
            uri = (target.url_base + uri) if uri[0..6].downcase != 'http://' && target.url_base
            uri = (target.url_pre  + uri) if target.url_pre
            uri = (uri + target.url_post) if target.url_post
            #
            yy, mm, dd = fix_date(dates[i]) if date
            hh, mn, ss = fix_time(times[i]) if time
            #
            if target.regexp_body
              if story = retrieve_url(uri)
                body = story.body.scan(Regexp.new(target.regexp_body,Regexp::MULTILINE)) # note forced multi-line regexp
                if body.empty?
                  # strange... got full text page && regexp, but no match found (maybe uri redirect?)
                  # safe best guess: ignore this story
                  ignore_story = 1
                else
                  fix_body = body.to_s
                  fix_body.gsub!(/\s*(<br ?\/?>\s*){2,}/i,'<p>')  # multiple <br>'s to <p>
                  fix_body.gsub!(/\n+/,'')                        # multiple newlines to nil
                  fix_body = strip_html(fix_body,['p','br','a'])
                  # date & time
                  if target.regexp_body_date
                    date  = Regexp.new(target.regexp_body_date)
                    dates = story.body.scan(date)
                    yy, mm, dd = fix_date(dates[0])
                  end
                  if target.regexp_body_time
                    time  = Regexp.new(target.regexp_body_time)
                    times = story.body.scan(time)
                    hh, mn, ss = fix_time(times[0])
                  end
                  # story image
                  if target.regexp_image
                    image = story.body.scan(Regexp.new(target.regexp_image))
                    if not image.empty?
                      image_url = image.to_s
                      image_url = (target.image_base ? target.image_base : target.url_base) + image_url if image_url[0..6].downcase != 'http://'
                    end
                  end
                end
              else
                # can't retrieve text uri
              end
            end
            #
            if ignore_story == 1
              puts "Ignoring story for #{uri}, (no text match)"
            else
              yy, mm, dd = fix_date(nil) unless (yy && mm && dd)
              hh, mn, ss = fix_time(nil) unless (hh && mn && ss)
              date_time  = yy + '-' + mm + '-' + dd + ' ' + hh + ':' + mn + ':' + ss
              #
              fix_title = strip_html(titles[i].to_s)
              fix_title = (target.title_pre + fix_title)  if target.title_pre
              fix_title = (fix_title + target.title_post) if target.title_post
              fix_intro = strip_html(intros[i].to_s)
              #
              dup = target.stories.size ? target.stories.find(:first, :conditions => ["url = ?", uri]) : nil
              if opt == 'update' || opt == 'save'
                if dup && opt == 'save'
                  # check for duplicate entries
                  puts "Duplicate entry for #{uri}, skipping."
                else
                  # save all new entries
                  print "Updating "  if opt == 'update'
                  print "Inserting " if opt == 'save'
                  puts "#{uri} ..."
                  if body
                    if image_url
                      Story.create(:target_id => target.id, :title => fix_title, :url => uri, :time => date_time, :intro => fix_intro, :body => fix_body, :image_url => image_url)
                    else
                      Story.create(:target_id => target.id, :title => fix_title, :url => uri, :time => date_time, :intro => fix_intro, :body => fix_body)
                    end
                  else
                    Story.create(:target_id => target.id, :title => fix_title, :url => uri, :time => date_time, :intro => fix_intro)
                  end
                end
              else
                # just show new available entries, if any
                if dup
                  puts "Already stored entry for #{uri}"
                else
                  puts '*** NEW ENTRY ***'
                  puts fix_title
                  puts uri
                  puts date_time
                  puts fix_intro
                  puts '---'     if fix_body
                  puts fix_body  if fix_body
                  puts '---'     if image_url
                  puts image_url if image_url
                end
              end
            end
            puts
          end
        else
          puts "\tError: Wrong URLs / Titles / Intros match."
        end
      else
        puts "\tError: Could not fetch page."
      end
    end
  end

  def test(target,regexp)
    if res = retrieve_url(target)
      rx = Regexp.new(regexp)
      hits = res.body.scan(rx)
      if hits.size
        hits.each_with_index { |hit,i| puts "#{i}) " + strip_html(hit.to_s) }
      else
        puts "\tNo match."
      end
    else
      puts "\tError: Could not fetch page."
    end
  end

  private

  #
  # retrieve remote url using browser-agent header
  #
  def retrieve_url(url)
    uri  = URI::parse(url)
    http = Net::HTTP.new(uri.host, uri.port).start
    res  = http.get(url,@headers)
    http.finish
    return res
  end

  #
  # strip html tags selectively
  #
  def strip_html(str,allow=['dm','dl'])
    str = str.strip || ''
    allow_arr = allow.join('|') << '|\/'
    str.gsub(/<(\/|\s)*[^(#{allow_arr})][^>]*>/,'').strip
  end

  #
  # fix date into YYYY/MM/DD format
  #
  def fix_date(date=nil)
    if date == nil
      # no full date, use current
      yy, mm, dd = Time.now.strftime("%Y/%m/%d").split('/')
    elsif date.size == 3
      # we got full date
      if date[0].size == 4
        # yyyy/mm/dd
        yy = date[0].strip
        mm = date[1].strip
        dd = date[2].strip.rjust(2,'0')
      else
        # dd/mm/yyyy
        dd = date[0].strip.rjust(2,'0')
        mm = date[1].strip
        yy = date[2].strip
      end
      case mm.downcase
        when 'enero' :
          mm = '01'
        when 'febrero' :
          mm = '02'
        when 'marzo' :
          mm = '03'
        when 'abril' :
          mm = '04'
        when 'mayo' :
          mm = '05'
        when 'junio' :
          mm = '06'
        when 'julio' :
          mm = '07'
        when 'agosto' :
          mm = '08'
        when 'setiembre' :
          mm = '09'
        when 'septiembre' :
          mm = '09'
        when 'octubre' :
          mm = '10'
        when 'noviembre' :
          mm = '11'
        when 'diciembre' :
          mm = '12'
        else
          mm.rjust(2,'0')
      end
    end
    return yy, mm, dd
  end

  #
  # fix time into HH:MN:SS format
  #
  def fix_time(time=nil)
    if time == nil
      # no full time, use current
      hh, mn, ss = Time.now.strftime("%H:%M:%S").split(':')
    elsif time.size == 3
      # we got full time
      hh = time[0].rjust(2,'0')
      mn = time[1].rjust(2,'0')
      ss = time[2].rjust(2,'0')
    elsif time.size == 2
      # we got full time minus seconds
      hh = time[0].rjust(2,'0')
      mn = time[1].rjust(2,'0')
      ss = Time.now.strftime("%S")
    end
    return hh, mn, ss
  end
end
