require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "debugvisualizer"
  gem 'nokogiri'
end

require 'nokogiri'
require 'open-uri'
require 'json'

# Array
ary = [1,70,10,3,40,30]

# Hash
hash = {"2020年6月": 120, "2020年7月": 80, "2020年8月": 150, "2020年9月": 180, "2020年10月": 220, "2020年11月": 100, "2020年12月": 50, "2021年1月": 300}

# Nokogiri
nokogiri = Nokogiri::HTML(URI.open("https://example.com/"))

# 要素数が2つ及びそれぞれの要素が String の Array
diff = [JSON.generate({orange:1, apple:2, banana:3}), JSON.generate({orange:2, apple:5, banana:3})]

foo = 1
