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

  def sites
    get('/sites')
  end

  # :title          => The title of the site (ie: RailsTips)
  # :service_value  => The domain of the site (ie: railstips.org)
  # :tz             => The time zone stats should be tracked in
  def create_site(params={})
    post('/sites', params)
  end

  def site(id)
    get("/sites/#{id}")
  end

  def update_site(id, params={})
    put("/sites/#{id}", params)
  end

  def delete_site(id)
    delete("/sites/#{id}")
  end

  def content(id, params={})
    get("/sites/#{id}/content", params)
  end

  def referrers(id, params={})
    get("/sites/#{id}/referrers", params)
  end

  def traffic(id, params={})
    get("/sites/#{id}/traffic", params)
  end

  def resolutions(id, params={})
    get("/sites/#{id}/resolutions", params)
  end

  def technology(id, params={})
    get("/sites/#{id}/technology", params)
  end

  def terms(id, params={})
    get("/sites/#{id}/terms")
  end

  def engines(id, params={})
    get("/sites/#{id}/engines", params)
  end

  def locations(id, params={})
    get("/sites/#{id}/locations", params)
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
