#!/bin/bash
export RUBYLIB=/usr/lib/ruby/1.8
export GEM_PATH=/usr/lib/ruby/gems/1.8/gems
cd /var/www/planetashop/current
rake parse:xml RAILS_ENV=production

