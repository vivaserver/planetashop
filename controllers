class HomeController < ApplicationController
  caches_page :index

  def index
    case @params['country']
      when 'brasil'
        url = 'http://www.mercadolivre.com.br'
      when 'chile'
        url = 'http://www.mercadolibre.cl'
      when 'colombia'
        url = 'http://www.mercadolibre.com.co'
      when 'ecuador'
        url = 'http://www.mercadolibre.com.ec'
      when 'mexico'
        url = 'http://www.mercadolibre.com.mx'
      when 'peru'
        url = 'http://www.mercadolibre.com.pe'
      when 'venezuela'
        url = 'http://www.mercadolibre.com.ve'
      when 'uruguay'
        url = 'http://www.mercadolibre.com.uy'
      else
        url = 'http://www.mercadolibre.com.ar'; @params['country'] = 'argentina'
    end
    order = @params['order'] ? @params['order'] : ''
    #
    user  = 'ELVENGADOR' # 'mauriciov'
    pass  = 'RUxWRU5HQURPUlZFTkdBRE9S' # 'TUFVUklDSU9WSUNJT1Y%3D'
    # first request just gets a gerenic xml for getting the total of items for pagination
    file  = Net::HTTP.get_response(URI.parse("#{url}/jm/searchXml?as_categ_id=1734"))
    total = (REXML::Document.new file.body).root.elements['listing'].attributes['items_total']
    if total = 0
      # no linux-specific category. try global 'linux' search
      req   = 'as_word=linux'
      file  = Net::HTTP.get_response(URI.parse("#{url}/jm/searchXml?#{req}"))
      total = (REXML::Document.new file.body).root.elements['listing'].attributes['items_total']
    else
      req = 'as_categ_id=1734'
    end
    req += "&as_order_id=#{order}&as_qshow=#{total}&user=#{user}&pwd=#{pass}"
    #
    file  = Net::HTTP.get_response(URI.parse("#{url}/jm/searchXml?#{req}"))
    if file
      @ml = REXML::Document.new file.body
      @pages, @items = paginate_collection @ml.elements.to_a('*/*/items/item'), :per_page => 8, :page => @params['page']
    else
      # no specific linux category to list. try global search
    end
    #
    @distros = Story.find :all
  end
end
