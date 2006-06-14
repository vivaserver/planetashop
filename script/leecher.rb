#!/usr/bin/ruby

require 'leech'

planetashop = Leech.new('planetashop_prod','root','')
if ARGV[0]
  planetashop.leecher(ARGV[0],(ARGV[1] if ARGV[1]))
else
  planetashop.leecher
end