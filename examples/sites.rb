$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'pp'
require 'rubygems'
require 'gauges'

ga = Gauges.new(:email => 'john@orderedlist.com', :password => 'testing')

puts 'Listing sites'
pp ga.sites.map { |site| site['service_value'] }
puts

puts 'Creating site'
site = ga.create_site({
  :title          => 'Testing',
  :service_value  => 'testing.com',
  :tz             => 'Eastern Time (US & Canada)'
})
pp site['title']
puts

puts 'Listing sites'
pp ga.sites.map { |site| site['service_value'] }
puts

puts 'Get site'
pp ga.site(site['id'])['title']
puts

puts 'Update site'
pp ga.update_site(site['id'], :title => 'New Title')['title']
puts

puts 'Get site'
pp ga.site(site['id'])['title']
puts

puts 'Deleting site'
pp ga.delete_site(site['id'])['title']
puts