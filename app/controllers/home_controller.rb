class HomeController < ApplicationController
  caches_page :index, :rss

  def index
    mercado  = Country.find_by_name(params[:country])
    @pages, @items = paginate_collection mercado.items, :per_page => 8, :page => (params[:page] || 1)
    @distros = Story.find(:all)
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
