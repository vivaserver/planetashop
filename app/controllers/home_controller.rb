class HomeController < ApplicationController
  caches_page :index, :rss

  def index
    mercado  = Country.find_by_name(params[:country])
    @pages, @items = paginate_collection mercado.items, :per_page => 8, :page => (params[:page] || 1)
    @distros = Story.find(:all)
  end
  
  def rss
    @mercado = Country.find_by_name(params[:country])
    @items   = @mercado.items[0..9]
    render(:layout => false)
  end
end
