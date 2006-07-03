class Item < ActiveRecord::Base
  belongs_to :country
  validates_presence_of :number, :title, :link, :currency, :price
  validates_format_of :link, :with => /^http:\/\/.+/i 
  validates_uniqueness_of :number, :link
end
