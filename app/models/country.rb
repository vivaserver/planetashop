class Country < ActiveRecord::Base
  has_many :items
  validates_presence_of :name, :title, :url_base
  validates_format_of :url_base, :with => /^http:\/\/.+/i
end
