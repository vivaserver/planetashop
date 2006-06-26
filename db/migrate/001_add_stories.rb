class AddStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
      t.column :target_id, :integer
      t.column :title, :string, :null => false
      t.column :url, :string, :null => false
      t.column :time, :datetime, :null => false
      t.column :intro, :text, :null => false
      t.column :body, :text
      t.column :notes, :text
      t.column :image_url, :string
      t.column :clicks, :integer
      t.column :is_not_in_home, :integer, :limit => 2, :default => '0'
      t.column :is_sticky, :integer, :limit => 2, :default => '0'
      t.column :is_unpublised, :integer, :limit => 2, :default => '0'
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :stories
  end
end
