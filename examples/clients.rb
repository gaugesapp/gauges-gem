$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'pp'
require 'rubygems'
require 'gauges'

ga = Gauges.new(:email => 'john@orderedlist.com', :password => 'testing')
pp ga.clients
pp ga.create_client(:description => 'Testing')
pp ga.clients
