ML_USER = 'ELVENGADOR'
ML_PASS = 'RUxWRU5HQURPUlZFTkdBRE9S'
# ML_USER = 'mauriciov'
# ML_PASS = 'TUFVUklDSU9WSUNJT1Y%3D'
ML_AFFL_SITE   = '332851'
ML_CATEG = '1734'
ML_SEARCH_WORD  = 'linux'

abs = File.expand_path(__FILE__)
path, file = File.split(abs)

require "#{path}/leecher"
require "#{path}/outrails"
require 'rexml/document'
require 'rexml/streamlistener'
require 'iconv'
include REXML

# Item = Struct.new(:country_id, :number, :title, :link, :image_url, :currency, :price, :bids, :hot, :hits, :auct_end)

class MLParse
  include StreamListener

  def initialize(id)
    @country_id = id
  end

  def tag_start(tag_name,attrs)
    @tag = tag_name
    case tag_name
      when 'item'
        @item = Item.new
        @item.number = attrs['id']
        @item.country_id  = @country_id
    end
  end

  def text(t)
    case @tag
      when 'title'
        #@item.title = t.unpack('U*').pack('c*') unless t =~ /^\s+/
        @item.title = Iconv.new("iso-8859-1","utf-8").iconv(t) unless t =~ /^\n\s+/
      when 'link'
        @item.link = t.gsub!('XXX',ML_AFFL_SITE) unless t =~ /^\n\s+/
      when 'image_url'
        @item.image_url = t unless t =~ /^\n\s+/
      when 'currency'
        @item.currency = t unless t =~ /^\n\s+/
      when 'price'
        @item.price = t unless t =~ /^\n\s+/
      when 'bids'
        @item.bids = t unless t =~ /^\n\s+/
      when 'hot'
        @item.hot = (t == 'Y' ? '1' : '0') unless t =~ /^\n\s+/
      when 'hits'
        @item.hits = t unless t =~ /^\n\s+/
      when 'auct_end'
        unless t =~ /^\n\s+/
          if t =~ /.+ (\d{2}) (.+) (\d{4}) (\d{2}):(\d{2}):(\d{2}) .+/
            dd = $1
            mm = $2
            yy = $3
            hh = $4
            mn = $5
            ss = $6
            case mm.downcase
              when 'jan' :
                mm = '01'
              when 'feb' :
                mm = '02'
              when 'mar' :
                mm = '03'
              when 'apr' :
                mm = '04'
              when 'may' :
                mm = '05'
              when 'jun' :
                mm = '06'
              when 'jul' :
                mm = '07'
              when 'aug' :
                mm = '08'
              when 'set' :
                mm = '09'
              when 'sep' :
                mm = '09'
              when 'oct' :
                mm = '10'
              when 'nov' :
                mm = '11'
              when 'dec' :
                mm = '12'
            end
            @item.auct_end = "#{yy}-#{mm}-#{dd} #{hh}:#{mn}:#{ss}"
          end
        end
    end
  end

  def tag_end(tag_name)
    if tag_name=='item'
      puts "Item #{@item.number} saved for #{@item.country.title}" if @item.save
    end
  end
end

l = Leecher.new
order = ''

Country.find(:all).each do |c|
  # first request just gets a gerenic xml for getting the total of items for pagination
  file  = l.retrieve_url("#{c.url_base}jm/searchXml?as_categ_id=#{ML_CATEG}")
  total = (REXML::Document.new(file.body)).root.elements['listing'].attributes['items_total']
  if total = 0
    # no linux-specific category. try global word search
    req   = "as_word=#{ML_SEARCH_WORD}"
    file  = l.retrieve_url("#{c.url_base}jm/searchXml?#{req}")
    total = (REXML::Document.new(file.body)).root.elements['listing'].attributes['items_total']
  else
    req = "as_categ_id=#{ML_CATEG}"
  end
  req += "&as_order_id=#{order}&as_qshow=#{total}&user=#{ML_USER}&pwd=#{ML_PASS}"
  #
  file = l.retrieve_url("#{c.url_base}jm/searchXml?#{req}")
  if file
    REXML::Document.parse_stream(file.body,MLParse.new(c.id))
  else
    # no specific linux category to list. try global search
  end
end


