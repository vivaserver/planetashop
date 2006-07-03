class Story < ActiveRecord::Base
  belongs_to :target
  validates_presence_of :title, :url, :time, :intro
  validates_format_of :url, :with => /^http:\/\/.+/i 
  validates_uniqueness_of :url
end
