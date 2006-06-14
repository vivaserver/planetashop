#!/bin/bash
cd /var/www/planetashop/public
rm index.html
rm argentina.html
rm argentina/*
rm brasil.html
rm brasil/*
rm chile.html
rm chile/*
rm colombia.html
rm colombia/*
rm ecuador.html
rm ecuador/*
rm mexico.html
rm mexico/*
rm peru.html
rm peru/*
rm uruguay.html
rm uruguay/*
rm venezuela.html
rm venezuela/*
./leecher.rb dw update
rm /tmp/ruby_sess*
