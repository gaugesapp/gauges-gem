require 'httparty'

class Gauges
  include HTTParty

  base_uri 'https://secure.gaug.es'

  # :token => http://get.gaug.es/documentation/api/authentication/
  def initialize(options={})
    @options = options
  end

  def me
    get('/me')
  end

  # :first_name, :last_name
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

  # :title => The title of the gauge (ie: RailsTips)
  # :tz    => The time zone stats should be tracked in
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

  def shares(id)
    get("/gauges/#{id}/shares")
  end

  # :email => The email of the user to add
  def share(id, params={})
    post("/gauges/#{id}/shares", params)
  end

  def unshare(id, user_id)
    delete("/gauges/#{id}/shares/#{user_id}")
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

  def token
    @options[:token]
  end

  def url(url)
    host, *parts = url.gsub(/https?\:\/\//, '').split('/')
    get("/#{parts.join('/')}")
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
    hash[:headers] ||= {}
    hash[:headers]['X-Gauges-Token'] = token
    hash
  end
end
