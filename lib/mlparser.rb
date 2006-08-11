# Item = Struct.new(:country_id, :number, :title, :link, :image_url, :currency, :price, :bids, :hot, :hits, :auct_end)
class MLParser
  require 'rexml/document'
  require 'rexml/streamlistener'
  require 'iconv'
  include REXML
  include StreamListener

  ML_USER        = 'ELVENGADOR'                 # 'mauriciov'
  ML_PASS        = 'RUxWRU5HQURPUlZFTkdBRE9S'   # 'TUFVUklDSU9WSUNJT1Y%3D'
  ML_CATEG       = '1734'
  ML_AFFL_SITE   = '332851'
  ML_SEARCH_WORD = 'linux'

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
        # this used to work before: @item.title = t.unpack('U*').pack('c*') unless t =~ /^\s+/
        @item.title = Iconv.new("iso-8859-1","utf-8").iconv(t) unless t =~ /^\n\s+/
      when 'link'
        @item.link = t.gsub!('XXX',ML_AFFL_SITE) unless t =~ /^\n\s+/
      when 'image_url'
        @item.image_url = t unless t =~ /^\n\s+/
      when 'seller_type'
        @item.seller_type = t unless t =~ /^\n\s+/
      when 'auction_type'
        @item.auction_type = t unless t =~ /^\n\s+/
      when 'mpago'
        @item.mpago = t unless t =~ /^\n\s+/
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
      when 'photo'
        @item.photo = (t == 'Y' ? '1' : '0') unless t =~ /^\n\s+/
      when 'highlight'
        @item.highlight = (t == 'Y' ? '1' : '0') unless t =~ /^\n\s+/
      when 'bold'
        @item.bold = (t == 'Y' ? '1' : '0') unless t =~ /^\n\s+/
    end
  end

  def tag_end(tag_name)
    if tag_name=='item'
      puts "Item #{@item.number} saved for #{@item.country.title}" if @item.save
    end
  end
end
