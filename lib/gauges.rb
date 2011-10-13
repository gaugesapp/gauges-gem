require 'httparty'

class Gauges
  include HTTParty

  base_uri 'api.gaug.es'

  # :email/:password or :token
  def initialize(options={})
    @options = options
  end

  def me
    get('/me')
  end

  # email, password, first_name, last_name
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

  def delete_client(id)
    delete("/clients/#{id}")
  end

  def gauges
    get('/gauges')
  end

  # :title          => The title of the gauge (ie: RailsTips)
  # :service_value  => The domain of the gauge (ie: railstips.org)
  # :tz             => The time zone stats should be tracked in
  def create_gauge(params={})
    post('/gauges', params)
  end

  def gauge(id)
    get("/gauges/#{id}")
  end

  def update_gauge(id, params={})
    put("/gauges/#{id}", params)
  end

  def delete_gauge(id)
    delete("/gauges/#{id}")
  end

  def content(id, params={})
    get("/gauges/#{id}/content", params)
  end

  def referrers(id, params={})
    get("/gauges/#{id}/referrers", params)
  end

  def traffic(id, params={})
    get("/gauges/#{id}/traffic", params)
  end

  def resolutions(id, params={})
    get("/gauges/#{id}/resolutions", params)
  end

  def technology(id, params={})
    get("/gauges/#{id}/technology", params)
  end

  def terms(id, params={})
    get("/gauges/#{id}/terms")
  end

  def engines(id, params={})
    get("/gauges/#{id}/engines", params)
  end

  def locations(id, params={})
    get("/gauges/#{id}/locations", params)
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

private
  def get(path, params={})
    self.class.get(path, options(:query => params))
  end

  def post(path, body={})
    self.class.post(path, options(:body => body))
  end

  def put(path, body={})
    self.class.put(path, options(:body => body))
  end

  def delete(path)
    self.class.delete(path, options)
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
