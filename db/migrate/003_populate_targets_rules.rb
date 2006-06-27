class PopulateTargetsRules < ActiveRecord::Migration
  def self.up
    target = Target.new(
      :id => '1',
      :name => 'distrowatch',
      :title => 'DistroWatch Monthly Top',
      :limit => 10,
      :url_target => 'http://distrowatch.com/index.php?dataspan=4',
      :url_base => 'http://distrowatch.com/table.php?distribution=',
      :regexp_title => '<th class="News">\d+<\/th>\s+<td class="News"><a href=".+">(.+)<\/a><\/td>',
      :regexp_url => '<th class="News">\d+<\/th>\s+<td class="News"><a href="(.+)">.+<\/a><\/td>',
      :regexp_intro => '<td class="News" style="text-align: right" title="Yesterday: \d{2,}">(\d{2,})<img src=',
      :regexp_body => '<\/tr>\s*<tr class="Background">\s*<td class="Info">(.+?)\s*<\/td>\s*<\/tr>\s*<\/table>',
      :regexp_image => '<th class="Info">Mirrors de descarga<\/th>\s+<td class="Info">\s*<a href="(\S+)">',
      :url_post => '&language=ES'
    )
    target.save
  end

  def self.down
    target = Target.find(1)
    target.destroy
  end
end
