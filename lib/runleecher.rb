abs = File.expand_path(__FILE__)
path, file = File.split(abs)

require "#{path}/leecher"

if ARGV[0] == 'test'
  target = 'http://distrowatch.com/index.php?dataspan=4'
  target = 'http://distrowatch.com/table.php?distribution=damnsmall&language=ES'
  target = 'http://distrowatch.com/table.php?distribution=ubuntu&language=ES'
  target = 'http://distrowatch.com/table.php?distribution=suse&language=ES'
  target = 'http://distrowatch.com/table.php?distribution=fedora&language=ES'
  #regexp = '<td class="News" style="text-align: right" title="Yesterday: \d{2,}">(\d{2,})<img src='
  #regexp = '<th class="News">\d+<\/th>\s+<td class="News"><a href="(.+)">.+<\/a><\/td>'
  #regexp = '<th class="News">\d+<\/th>\s+<td class="News"><a href=".+">(.+)<\/a><\/td>'
  regexp = '<\/tr>\s*<tr class="Background">\s*<td class="Info">(.+)\s*<\/td>\s*<\/tr>\s*<\/table>'
  #
  l = Leecher.new
  l.test(target,regexp)
else
  require 'yaml'
  require 'rubygems'
  require_gem 'activerecord'

  conf = YAML::load_file("#{path[0..-4]}/config/database.yml")
  database = conf[ARGV[0]]['database']

  ActiveRecord::Base.establish_connection(
    :adapter  => conf[ARGV[0]]['adapter'],
    :database => "#{path[0..-4]}/#{database}"
  )

  class Story < ActiveRecord::Base
    belongs_to :target
  end

  class Target < ActiveRecord::Base
    has_many :stories
    validates_uniqueness_of :url
  end

  Target.find(:all).each do |t|
    l = Leecher.new
    l.leech(t,ARGV[1].to_s)
  end
end
