class AddTargets < ActiveRecord::Migration
  def self.up
    create_table :targets do |t|
      t.column :category_id, :integer
      t.column :name, :string, :null => false
      t.column :title, :string, :null => false
      t.column :intro, :text
      t.column :body, :text
      t.column :notes, :text
      t.column :limit, :integer
      t.column :url_target, :text, :null => false
      t.column :url_base, :text
      t.column :image_base, :text
      t.column :regexp_title, :text, :null => false
      t.column :regexp_url, :text, :null => false
      t.column :regexp_date, :text
      t.column :regexp_time, :text
      t.column :regexp_intro, :text, :null => false
      t.column :regexp_body, :text
      t.column :regexp_body_date, :text
      t.column :regexp_body_time, :text
      t.column :regexp_notes, :text
      t.column :regexp_image, :text
      t.column :title_pre, :text
      t.column :title_post, :text
      t.column :url_pre, :text
      t.column :url_post, :text
      t.column :last_checked, :datetime
      t.column :parse_errors, :integer, :default => '0'
      t.column :is_disabled, :integer, :limit => 2, :default => '0'
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :targets
  end
end
