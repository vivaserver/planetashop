class HomeController < ApplicationController
  caches_page :index

  def index
    mercado  = Country.find_by_name(params[:country])
    @pages, @items = paginate_collection mercado.items.sort_by { |i| i.hot }.reverse, :per_page => 8, :page => params[:page]
    @distros = Story.find(:all)
  end
end
