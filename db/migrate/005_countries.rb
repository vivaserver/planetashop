class Countries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.column :name,        :string,  :null    => false
      t.column :title,       :string,  :null    => false
      t.column :url_base,    :string,  :null    => false
      t.column :items_count, :integer, :default => '0'
    end
    country = Country.create(
      :name     => 'argentina',
      :title    => 'Argentina',
      :url_base => 'http://www.mercadolibre.com.ar/'
    )
    country = Country.create(
      :name     => 'brasil',
      :title    => 'Brasil',
      :url_base => 'http://www.mercadolivre.com.br/'
    )
    country = Country.create(
      :name     => 'chile',
      :title    => 'Chile',
      :url_base => 'http://www.mercadolibre.cl/'
    )
    country = Country.create(
      :name     => 'colombia',
      :title    => 'Colombia',
      :url_base => 'http://www.mercadolibre.com.co/'
    )
    country = Country.create(
      :name     => 'ecuador',
      :title    => 'Ecuador',
      :url_base => 'http://www.mercadolibre.com.ec/'
    )
    country = Country.create(
      :name     => 'mexico',
      :title    => 'Mexico',
      :url_base => 'http://www.mercadolibre.com.mx/'
    )
    country = Country.create(
      :name     => 'peru',
      :title    => 'Peru',
      :url_base => 'http://www.mercadolibre.com.pe/'
    )
    country = Country.create(
      :name     => 'venezuela',
      :title    => 'Venezuela',
      :url_base => 'http://www.mercadolibre.com.ve/'
    )
    country = Country.create(
      :name     => 'uruguay',
      :title    => 'Uruguay',
      :url_base => 'http://www.mercadolibre.com.uy/'
    )
    add_index :countries, :name
  end

  def self.down
    drop_table :countries
  end
end
