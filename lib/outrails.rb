# loads all rails models w/o full environment
module OutRails
  require 'yaml'
  require 'rubygems'
  require_gem 'activerecord'

  def load_models(path)
    if ARGV.size > 0
      ARGV.each { |arg|
        case arg
          when /--env=(development|production|test)/
            @env = $1
          when /--(save|update)/
            @opt = $1
          when /--limit=(\d{1,2})/
            @limit  = $1
          when /--target=(.+)/
            @target = $1
        end
      }
    end

    @env ||= 'development'
    conf = YAML::load_file("#{path[0..-4]}/config/database.yml")

    case conf[@env]['adapter']
      when 'mysql'
        ActiveRecord::Base.establish_connection(
          :adapter  => conf[@env]['adapter'],
          :database => conf[@env]['database'],
          :username => conf[@env]['username'],
          :password => conf[@env]['password'],
          :socket   => conf[@env]['socket']
        )
      when 'sqlite'
      when 'sqlite3'
        ActiveRecord::Base.establish_connection(
          :adapter  => conf[@env]['adapter'],
          :database => "#{path[0..-4]}/#{conf[@env]['database']}"
        )
    end

    Dir.chdir("#{path[0..-4]}/app/models") { |d|
      Dir.glob('*.rb') { |f| puts "loaded model #{f.capitalize}" if require f }
    }
    puts
  end
end
