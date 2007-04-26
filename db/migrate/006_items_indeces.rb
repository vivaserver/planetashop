class ItemsIndeces < ActiveRecord::Migration
  def self.up
    add_index :items, :hot
    add_index :items, :hits
  end

  def self.down
    remove_index :items, :hot
    remove_index :items, :hits
  end
end
