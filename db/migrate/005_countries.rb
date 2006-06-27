class Countries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.column :name, :string, :null => false
      t.column :title, :string, :null => false
      t.column :url_base, :string, :null => false
    end
    country = Country.new(
      :name => 'argentina',
      :title => 'Argentina',
      :url_base => 'http://www.mercadolibre.com.ar/'
    )
    country.save
    country = Country.new(
      :name => 'brasil',
      :title => 'Brasil',
      :url_base => 'http://www.mercadolivre.com.br/'
    )
    country.save
    country = Country.new(
      :name => 'chile',
      :title => 'Chile',
      :url_base => 'http://www.mercadolibre.cl/'
    )
    country.save
    country = Country.new(
      :name => 'colombia',
      :title => 'Colombia',
      :url_base => 'http://www.mercadolibre.com.co/'
    )
    country.save
    country = Country.new(
      :name => 'ecuador',
      :title => 'Ecuador',
      :url_base => 'http://www.mercadolibre.com.ec/'
    )
    country.save
    country = Country.new(
      :name => 'mexico',
      :title => 'Mexico',
      :url_base => 'http://www.mercadolibre.com.mx/'
    )
    country.save
    country = Country.new(
      :name => 'peru',
      :title => 'Peru',
      :url_base => 'http://www.mercadolibre.com.pe/'
    )
    country.save
    country = Country.new(
      :name => 'venezuela',
      :title => 'Venezuela',
      :url_base => 'http://www.mercadolibre.com.ve/'
    )
    country.save
    country = Country.new(
      :name => 'uruguay',
      :title => 'Uruguay',
      :url_base => 'http://www.mercadolibre.com.uy/'
    )
    country.save
  end

  def self.down
    drop_table :countries
  end
end
