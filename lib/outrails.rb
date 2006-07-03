# load all rails models w/o full environment

require 'yaml'
require 'rubygems'
require_gem 'activerecord'

abs = File.expand_path(__FILE__)
path, file = File.split(abs)

env  = ARGV.size == 0 ? 'development' : ARGV[0]
conf = YAML::load_file("#{path[0..-4]}/config/database.yml")
data = conf[env]['database']

ActiveRecord::Base.establish_connection(
  :adapter  => conf[env]['adapter'],
  :database => "#{path[0..-4]}/#{data}"
)

Dir.chdir("#{path[0..-4]}/app/models") { |d| 
  Dir.glob('*.rb') { |f| puts "loaded model #{f.capitalize}" if require f }
}
puts
