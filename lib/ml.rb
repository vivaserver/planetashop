# url for test XML
# http://www.mercadolibre.com.ar/jm/searchXml?as_categ_id=1734&user=ELVENGADOR&pwd=RUxWRU5HQURPUlZFTkdBRE9S&as_qshow=43

require 'rexml/document'
require 'rexml/streamlistener'
require 'iconv'
include REXML

Item = Struct.new(:item_id, :title, :link, :image_url, :currency, :price, :hot)

class MLParse
  include StreamListener
  
  def tag_start(tag_name,attrs) 
    @tag = tag_name
    case tag_name
      when 'item'
        @item = Item.new
        @item.item_id = attrs['id']
    end
  end
  
  def text(t)
    case @tag
      when 'title'       
        #@item.title = t.unpack('U*').pack('c*') unless t =~ /^\s+/
        @item.title = Iconv.new("iso-8859-1","utf-8").iconv(t) unless t =~ /^\s+/
      when 'link'
        @item.link = t.gsub!('XXX','332851') unless t =~ /^\s+/
      when 'image_url'
        @item.image_url = t unless t =~ /^\s+/
      when 'currency'
        @item.currency = t unless t =~ /^\s+/
      when 'price'
        @item.price = t unless t =~ /^\s+/
      when 'hot'
        @item.hot = t unless t =~ /^\s+/
    end
  end
  
  def tag_end(tag_name)
    p @item if tag_name=='item'
  end
end

Document.parse_stream(File.new('ml.xml'),MLParse.new)

