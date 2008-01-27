# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :application, "planetashop"
set :repository, "svn+ssh://69.61.74.106/home/repos/#{application}/trunk"

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, "www.planetalinuxshop.com.ar"
role :app, "www.planetalinuxshop.com.ar"
role :db,  "www.planetalinuxshop.com.ar", :primary => true

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
set :deploy_to, "/var/www/#{application}" # defaults to "/u/apps/#{application}"
# set :user, "flippy"            # defaults to the currently logged in user
# set :scm, :darcs               # defaults to :subversion
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25

# following line to fix Net::SSH::HostKeyMismatch error. 
# see http://railspikes.com/2007/5/10/capistrano-bug-net-ssh-hostkeymismatch
# also from OS X run "sudo cap ..." to get it working
ssh_options[:paranoid] = false

# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)

desc <<DESC
An imaginary backup task. (Execute the 'show_tasks' task to display all
available tasks.)
DESC
task :backup, :roles => :db, :only => { :primary => true } do
  # the on_rollback handler is only executed if this task is executed within
  # a transaction (see below), AND it or a subsequent task fails.
  on_rollback { delete "/tmp/dump.sql" }

  run "mysqldump -u theuser -p thedatabase > /tmp/dump.sql" do |ch, stream, out|
    ch.send_data "thepassword\n" if out =~ /^Enter password:/
  end
end

# Tasks may take advantage of several different helper methods to interact
# with the remote server(s). These are:
#
# * run(command, options={}, &block): execute the given command on all servers
#   associated with the current task, in parallel. The block, if given, should
#   accept three parameters: the communication channel, a symbol identifying the
#   type of stream (:err or :out), and the data. The block is invoked for all
#   output from the command, allowing you to inspect output and act
#   accordingly.
# * sudo(command, options={}, &block): same as run, but it executes the command
#   via sudo.
# * delete(path, options={}): deletes the given file or directory from all
#   associated servers. If :recursive => true is given in the options, the
#   delete uses "rm -rf" instead of "rm -f".
# * put(buffer, path, options={}): creates or overwrites a file at "path" on
#   all associated servers, populating it with the contents of "buffer". You
#   can specify :mode as an integer value, which will be used to set the mode
#   on the file.
# * render(template, options={}) or render(options={}): renders the given
#   template and returns a string. Alternatively, if the :template key is given,
#   it will be treated as the contents of the template to render. Any other keys
#   are treated as local variables, which are made available to the (ERb)
#   template.

desc "Demonstrates the various helper methods available to recipes."
task :helper_demo do
  # "setup" is a standard task which sets up the directory structure on the
  # remote servers. It is a good idea to run the "setup" task at least once
  # at the beginning of your app's lifetime (it is non-destructive).
  setup

  buffer = render("maintenance.rhtml", :deadline => ENV['UNTIL'])
  put buffer, "#{shared_path}/system/maintenance.html", :mode => 0644
  sudo "killall -USR1 dispatch.fcgi"
  run "#{release_path}/script/spin"
  delete "#{shared_path}/system/maintenance.html"
end

# You can use "transaction" to indicate that if any of the tasks within it fail,
# all should be rolled back (for each task that specifies an on_rollback
# handler).

desc "A task demonstrating the use of transactions."
task :long_deploy do
  transaction do
    update_code
    disable_web
    symlink
    migrate
  end

  restart
  enable_web
end

# always run leechers after deploy_with_migrations
desc "Always run leecher & parser after deploy with migrations"
task :after_deploy_with_migrations do
  first_time_leech
end

# runleecher, use it after the first deploy_with_migrations
desc "Run leecher for the first time..."
task :first_time_leech do
  sudo "chmod 0755 #{release_path}/lib/leech"
  sudo "#{release_path}/lib/leech --save --env=production"
  # first migration creates log files as root user, so chmod them back to www-data user/group
  after_setup
end

# xML parser, use it after the first deploy_with_migrations
desc 'New Hpricot xML parser'
task :parse_xml do
  run "cd #{current_path} && rake parse:xml RAILS_ENV=production"
end
task :clear_cache do
  run "cd #{current_path} && rake parse:clear_cache RAILS_ENV=production"
end

# thanks to http://litespeedtech.com/support/wiki/doku.php?id=litespeed_wiki:capistrano
desc 'Set www-data user/group permission to deployed release tree'
task :after_update_code do
  sudo "chown -R www-data:www-data #{release_path}"
end
task :after_setup do
  sudo "touch #{deploy_to}/shared/log/fastcgi.crash.log"
  sudo "touch #{deploy_to}/shared/log/production.log"
  sudo "chown -R www-data:www-data #{deploy_to}/shared"
end

#
# following rules require that the /etc/lighttpd/lighttpd.conf includes a line like:
#  include "../../var/www/planetashop/current/config/lighttpd.conf"
#
desc 'Replace vhost config with maintenance config & restart lighttpd'
task :after_disable_web do
  sudo "rm #{current_path}/config/lighttpd.conf"
  sudo "cp #{current_path}/config/lighttpd.maintenance #{current_path}/config/lighttpd.conf"
  sudo "/etc/init.d/lighttpd restart"
end

desc 'Replace maintenance config with vhost config & restart lighttpd'
task :after_enable_web do
  sudo "rm #{current_path}/config/lighttpd.conf"
  sudo "cp #{current_path}/config/lighttpd.production #{current_path}/config/lighttpd.conf"
  sudo "/etc/init.d/lighttpd restart"
end

