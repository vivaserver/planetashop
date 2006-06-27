abs = File.expand_path(__FILE__)
path, file = File.split(abs)

require "#{path}/leecher"
l = Leecher.new

if ARGV[0] == 'test'
  target = 'http://distrowatch.com/index.php?dataspan=4'
  target = 'http://distrowatch.com/table.php?distribution=debian&language=ES'
  target = 'http://distrowatch.com/table.php?distribution=damnsmall&language=ES'
  target = 'http://distrowatch.com/table.php?distribution=fedora&language=ES'
  target = 'http://distrowatch.com/table.php?distribution=suse&language=ES'
  #regexp = '<td class="News" style="text-align: right" title="Yesterday: \d{2,}">(\d{2,})<img src='
  #regexp = '<th class="News">\d+<\/th>\s+<td class="News"><a href="(.+)">.+<\/a><\/td>'
  #regexp = '<th class="News">\d+<\/th>\s+<td class="News"><a href=".+">(.+)<\/a><\/td>'
  #regexp = '<\/tr>\s*<tr class="Background">\s*<td class="Info">(.+)\s*<\/td>\s*<\/tr>\s*<\/table>'
  regexp = '<th class="Info">Mirrors de descarga<\/th>\s+<td class="Info">\s*<a href="(\S+)">'
  #
  l.test(target,regexp)
else
  require "#{path}/outrails"

  Target.find(:all).each { |t| l.leech(t,ARGV[1].to_s) }
end
