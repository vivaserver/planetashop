class HomeController < ApplicationController

  def index
    @distros = Story.find(:all)
    @items   = Item.available(params[:country],params[:page])
  end
  
  def rss
    # set Content-Type header as explained in http://nubyonrails.com/articles/2006/02/01/rjs-and-content-type-header
    # this is to pass a successful validation from http://feedvalidator.org/
    headers['Content-Type'] = 'application/xml'
    @items = Item.available(params[:country])
    render :layout => false
  end
  
  def unrecognized
    # NOTE: catch-all unrecognized URLs, removed default last routing rule (see routes.rb)
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
  end
end
