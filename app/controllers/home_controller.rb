class HomeController < ApplicationController

  def index
    @distros = Story.find(:all)
    @items   = Item.paginate_by_sql(["select i.* from items as i join countries as c on i.country_id = c.id where c.name = ?", params[:country]], :page => params[:page], :per_page => 8)
  end
  
  def rss
    # set Content-Type header as explained in http://nubyonrails.com/articles/2006/02/01/rjs-and-content-type-header
    # this is to pass a successful validation from http://feedvalidator.org/
    headers['Content-Type'] = 'application/xml'
    @mercado = Country.find_by_name(params[:country])
    @items   = @mercado.items[0..9]
    render(:layout => false)
  end
end
