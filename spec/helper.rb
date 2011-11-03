$:.unshift(File.expand_path('../../lib', __FILE__))

require 'gauges'

require 'pathname'
require 'logger'

ProjectRootPath = Pathname(__FILE__).dirname.join('..').expand_path
log_path  = ProjectRootPath.join('log')
log_path.mkpath

require 'rubygems'
require 'bundler'

Bundler.require(:test)

Logger.new(log_path.join('test.log')).tap do |log|
  LogBuddy.init(:logger => log)
end

module FakeRequestHelpers
  def fixture(name)
    ProjectRootPath.join('spec', 'fixtures', name.to_s).read
  end

  def stub_get(url, name)
    FakeWeb.register_uri(:get, url, :response => fixture(name))
  end

  def stub_post(url, name)
    FakeWeb.register_uri(:post, url, :response => fixture(name))
  end

  def stub_put(url, name)
    FakeWeb.register_uri(:put, url, :response => fixture(name))
  end

  def stub_delete(url, name)
    FakeWeb.register_uri(:delete, url, :response => fixture(name))
  end
end

RSpec.configure do |c|
  c.include(FakeRequestHelpers)

  c.before(:each) do
    FakeWeb.clean_registry
  end
end

FakeWeb.allow_net_connect = false

# Creating fixtures:
# curl -is -H "X-Gauges-Token: <token here>" https://secure.gaug.es/gauges/1234 > spec/fixtures/gauge_not_found