class Item < ActiveRecord::Base
  belongs_to :country, :counter_cache => true
  validates_presence_of :number, :title, :link, :currency, :price
  validates_format_of :link, :with => /^http:\/\/.+/i 
  # no uniqueness validation because we reload the items and delete older when parsing the xML
  # validates_uniqueness_of :number, :link
end
