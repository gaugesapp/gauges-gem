$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'pp'
require 'rubygems'
require 'gauges'

id = '4d5f4992089bb618a2000005'
ga = Gauges.new(:token => '...')

response = ga.content(id)
pp response['content'].size

response = ga.content(id, :page => 2)
pp response['content'].size

response = ga.content(id, :page => 3)
pp response['content'].size

response = ga.content(id, :date => '2011-08-01')
pp response['content'].size
