# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  require 'uri'
  require 'net/http'
  require 'rexml/document'
  
  session :off

  def paginate_collection(collection, options = {})
    default_options = {:per_page => 10, :page => 1}
    #
    options = default_options.merge options
    pages   = Paginator.new self, collection.size, options[:per_page], options[:page]
    #
    first = pages.current.offset
    last  = [first + options[:per_page], collection.size].min
    slice = collection[first...last]
    #
    return [pages, slice]
  end
end
