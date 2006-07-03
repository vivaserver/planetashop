class Target < ActiveRecord::Base
  has_many :stories
  validates_presence_of :name, :title, :url_target, :regexp_title, :regexp_url, :regexp_intro
  validates_format_of :url_target, :with => /^http:\/\/.+/i 
end
