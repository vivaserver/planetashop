class Country < ActiveRecord::Base
  has_many :items, :order => 'hot desc, hits desc'
  validates_presence_of :name, :title, :url_base
  validates_format_of :url_base, :with => /^http:\/\/.+/i
end
