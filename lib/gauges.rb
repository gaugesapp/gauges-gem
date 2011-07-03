require 'httparty'

class Gauges
  include HTTParty

  base_uri 'api.gaug.es'

  def initialize(options={})
    @options = options
  end

  def email
    @options[:email]
  end

  def password
    @options[:password]
  end

  def basic_auth
    {:username => email, :password => password}
  end

  def clients
    get('/clients')
  end

  # :description => Any text describing what this client is or will be used for (ie: Campfire, GitHub, HipChat...)
  def create_client(params={})
    post('/clients', params)
  end

private
  def get(path)
    self.class.get(path, options)
  end

  def post(path, body={})
    self.class.post(path, options(:body => body))
  end

  def options(hash={})
    hash.merge(:basic_auth => basic_auth)
  end
end
