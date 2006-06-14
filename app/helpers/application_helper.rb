# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # snippet from http://www.bigbold.com/snippets/posts/show/509
  def stylesheet_auto_link_tags
    stylesheets_path = "#{RAILS_ROOT}/public/stylesheets/"
    candidates = [ "#{controller.controller_name}", "#{controller.controller_name}_#{controller.action_name}" ]
    candidates.inject("") do |buf, css|
      buf << stylesheet_link_tag(css) if FileTest.exist?("#{stylesheets_path}/#{css}.css")
      buf
    end
  end

end
