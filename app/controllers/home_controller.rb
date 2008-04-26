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
end
