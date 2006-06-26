class Story < ActiveRecord::Base
  belongs_to :target
  validates_uniqueness_of :url
end
