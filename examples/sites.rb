$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'pp'
require 'rubygems'
require 'gauges'

ga = Gauges.new(:email => 'john@orderedlist.com', :password => 'testing')
pp ga.sites.map { |site| site['service_value'] }

site = ga.create_site({
  :title          => 'Testing',
  :service_value  => 'testing.com',
  :tz             => 'Eastern Time (US & Canada)'
})
pp site

pp ga.sites.map { |site| site['service_value'] }

pp ga.site(site['id'])