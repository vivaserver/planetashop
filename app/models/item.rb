class Item < ActiveRecord::Base
  belongs_to :country, :counter_cache => true
  validates_presence_of :number, :title, :link, :currency, :price
  validates_format_of :link, :with => /^http:\/\/.+/i 
  # no uniqueness validation because we reload the items and delete older when parsing the xML
  # validates_uniqueness_of :number, :link
  
  def self.available(country,page=1)
    paginate :conditions => ['country_id = ?', { 'argentina' => 1, 'brasil' => 2, 'chile' => 3, 'colombia' => 4, 'ecuador' => 5, 'mexico' => 6, 'peru' => 7, 'venezuela' => 8, 'uruguay' => 9 }[country]],
             :per_page => 8,
             :page => page
             # commented out because this order always returns the same popular items, newer never got the Home page
             # :order => 'hot desc, hits desc',
  end
end
