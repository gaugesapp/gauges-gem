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

  def token
    @options[:token]
  end

  def basic_auth?
    @options.key?(:email) && @options.key?(:password)
  end

  def header_auth?
    !basic_auth?
  end

  def me
    get('/me')
  end

  def update_me(params={})
    put('/me', params)
  end

  def clients
    get('/clients')
  end

  # :description => Any text describing what this client is or will be used for (ie: Campfire, GitHub, HipChat...)
  def create_client(params={})
    post('/clients', params)
  end

  def sites
    get('/sites')
  end

private
  def get(path)
    self.class.get(path, options)
  end

  def post(path, body={})
    self.class.post(path, options(:body => body))
  end

  def put(path, body={})
    self.class.put(path, options(:body => body))
  end

  def options(hash={})
    if basic_auth?
      hash.merge!(:basic_auth => basic_auth)
    else
      hash[:headers] ||= {}
      hash[:headers]['X-Gauges-Token'] = token
    end

    hash
  end

  def basic_auth
    {:username => email, :password => password}
  end
end
