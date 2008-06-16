ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.

  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  map.home '', :controller => 'home', :country => 'argentina'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  map.connect ':country/:page', :controller => 'home', :country => nil, :page => nil, :requirements => {:country => /(argentina|brasil|chile|colombia|ecuador|mexico|peru|venezuela|uruguay)/, :page => /\d{1,2}/}
  map.connect ':country/rss', :controller => 'home', :action => 'rss', :requirements => {:country => /(argentina|brasil|chile|colombia|ecuador|mexico|peru|venezuela|uruguay)/}
  
  map.connect '*path', :controller => 'home', :action => 'unrecognized'

  # Install the default route as the lowest priority.
  # map.connect ':controller/:action/:id'
end
