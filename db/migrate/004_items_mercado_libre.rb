class ItemsMercadoLibre < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.column :country_id,   :integer
      t.column :number,       :integer, :null => false
      t.column :title,        :string,  :null => false
      t.column :link,         :string,  :null => false
      t.column :image_url,    :string
      t.column :seller_type,  :string
      t.column :auction_type, :string
      t.column :mpago,        :integer, :default => '0', :limit => 2
      t.column :currency,     :string,  :null => false
      t.column :price,        :float,   :null => false
      t.column :bids,         :integer, :default => '0'
      t.column :hot,          :integer, :default => '0', :limit => 2
      t.column :hits,         :integer, :default => '0'
      t.column :auct_end,     :datetime
      t.column :photo,        :integer, :default => '0', :limit => 2
      t.column :highlight,    :integer, :default => '0', :limit => 2
      t.column :bold,         :integer, :default => '0', :limit => 2
      t.column :created_at,   :datetime
    end
  end

  def self.down
    drop_table :items
  end
end
