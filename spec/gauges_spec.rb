require 'helper'

describe Gauges do
  context "initializing with token" do
    before do
      @client = Gauges.new(:token => 'asdf')
    end

    it "sets token" do
      @client.token.should == 'asdf'
    end
  end

  context "http auth failure" do
    before do
      stub_get('https://secure.gaug.es/clients', :clients_http_auth_failure)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.clients
    end

    it "returns status" do
      @response['status'].should == 'fail'
    end

    it "returns message" do
      @response['message'].should == 'Authentication required'
    end

    it "has correct status code" do
      @response.code.should == 401
    end

    it "returns correct content type" do
      @response.headers['content-type'].should == 'application/json'
    end
  end

  context "making request with token" do
    before do
      stub_get('https://secure.gaug.es/me', :me)
      @client = Gauges.new(:token => 'asdf')
    end

    it "sets token header for request" do
      Gauges.should_receive(:get).with('/me', :headers => {
        'X-Gauges-Token' => 'asdf'
      }, :query => {})
      @client.me
    end
  end

  describe "#me" do
    before do
      stub_get('https://secure.gaug.es/me', :me)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.me
    end

    it "returns my own information" do
      @response['user']['id'].should          == '4df37acbe5947cabdd000001'
      @response['user']['name'].should        == 'john@doe.com'
      @response['user']['email'].should       == 'john@doe.com'
      @response['user']['first_name'].should  == nil
      @response['user']['last_name'].should   == nil
      @response['user']['urls']['self'].should        == 'https://secure.gaug.es/me'
      @response['user']['urls']['gauges'].should      == 'https://secure.gaug.es/gauges'
      @response['user']['urls']['clients'].should     == 'https://secure.gaug.es/clients'
    end
  end

  describe "#clients" do
    before do
      stub_get('https://secure.gaug.es/clients', :clients)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.clients
    end

    it "returns a clients hash" do
      @response.should be_instance_of(Hash)
      @response['clients'].size.should be(1)

      client = @response['clients'].first
      client['key'].should          == '6c6b748646bb371a0027683cda32b7ff'
      client['created_at'].should   == Time.utc(2011, 11, 2, 15, 17, 53)
      client['description'].should  == 'HipChat'
      client['urls']['self'].should == 'https://secure.gaug.es/clients/6c6b748646bb371a0027683cda32b7ff'
    end
  end

  describe "#create_client" do
    before do
      stub_post('https://secure.gaug.es/clients', :client_create)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.create_client(:description => 'HipChat')
    end

    it "returns 201" do
      @response.code.should == 201
    end

    it "returns created client" do
      @response.should be_instance_of(Hash)

      @response['client']['key'].should         == '6c6b748646bb371a0027683cda32b7ff'
      @response['client']['description'].should == 'HipChat'
      @response['client']['created_at'].should  == Time.utc(2011, 11, 2, 15, 17, 53)
      @response['client']['urls']['self'].should == 'https://secure.gaug.es/clients/6c6b748646bb371a0027683cda32b7ff'
    end
  end

  describe "#delete_client" do
    before do
      stub_delete('https://secure.gaug.es/clients/6c6b748646bb371a0027683cda32b7ff', :client_delete)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.delete_client('6c6b748646bb371a0027683cda32b7ff')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns client" do
      @response['client']['key'].should         == '6c6b748646bb371a0027683cda32b7ff'
      @response['client']['description'].should == 'HipChat'
      @response['client']['created_at'].should  == Time.utc(2011, 11, 2, 15, 17, 53)
      @response['client']['urls']['self'].should == 'https://secure.gaug.es/clients/6c6b748646bb371a0027683cda32b7ff'
    end
  end

  describe "#update_me" do
    context "valid" do
      before do
        stub_put('https://secure.gaug.es/me', :me_update)
        @client = Gauges.new(:token => 'asdf')
        @response = @client.update_me(:first_name => 'Frank', :last_name => 'Furter')
      end

      it "returns 200" do
        @response.code.should == 200
      end

      it "returns update user" do
        @response.should be_instance_of(Hash)
        @response['user']['id'].should          == '4df37acbe5947cabdd000001'
        @response['user']['name'].should        == 'john@doe.com'
        @response['user']['first_name'].should  == 'Joe'
        @response['user']['last_name'].should   == nil
        @response['user']['email'].should       == 'john@doe.com'
        @response['user']['urls']['self'].should    == 'https://secure.gaug.es/me'
        @response['user']['urls']['gauges'].should  == 'https://secure.gaug.es/gauges'
        @response['user']['urls']['clients'].should == 'https://secure.gaug.es/clients'
      end
    end
  end

  describe "#gauges" do
    before do
      stub_get('https://secure.gaug.es/gauges', :gauges)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.gauges
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns Hash" do
      @response.should be_instance_of(Hash)
    end

    it "returns gauges" do
      gauge = @response['gauges'][0]

      gauge['title'].should         == 'acme.com'
      gauge['tz'].should            == 'Eastern Time (US & Canada)'
      gauge['id'].should            == '4d597dfd6bb4ba2c48000003'
      gauge['creator_id'].should    == '4df37acbe5947cabdd000001'
      gauge['now_in_zone'].should   == Time.parse('Wed Nov 02 21:11:53 -0400 2011')
      gauge['enabled'].should       == true

      gauge['urls']["self"].should        == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003"
      gauge['urls']["shares"].should      == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/shares"
      gauge['urls']["referrers"].should   == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/referrers"
      gauge['urls']["technology"].should  == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/technology"
      gauge['urls']["content"].should     == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/content"
      gauge['urls']["locations"].should   == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/locations"
      gauge['urls']["engines"].should     == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/engines"
      gauge['urls']["terms"].should       == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/terms"
      gauge['urls']["resolutions"].should == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/resolutions"
      gauge['urls']["traffic"].should     == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/traffic"

      gauge['all_time'].should      == {"views" => 8259, "people" => 5349}
      gauge['today'].should         == {"date" => Date.new(2011, 11, 2), "views" => 53, "people" => 29}
      gauge['yesterday'].should     == {"date" => Date.new(2011, 11, 1), "views" => 137, "people" => 72}

      gauge['recent_hours'].should  == [
        {"hour"=>"21", "views"=>0,  "people"=>0},
        {"hour"=>"20", "views"=>0,  "people"=>0},
        {"hour"=>"19", "views"=>0,  "people"=>0},
        {"hour"=>"18", "views"=>0,  "people"=>0},
        {"hour"=>"17", "views"=>0,  "people"=>0},
        {"hour"=>"16", "views"=>0,  "people"=>0},
        {"hour"=>"15", "views"=>0,  "people"=>0},
        {"hour"=>"14", "views"=>0,  "people"=>0},
        {"hour"=>"13", "views"=>0,  "people"=>0},
        {"hour"=>"12", "views"=>0,  "people"=>0},
        {"hour"=>"11", "views"=>1,  "people"=>1},
        {"hour"=>"10", "views"=>8,  "people"=>4},
        {"hour"=>"09", "views"=>12, "people"=>9},
        {"hour"=>"08", "views"=>9,  "people"=>6},
        {"hour"=>"07", "views"=>1,  "people"=>0},
        {"hour"=>"06", "views"=>4,  "people"=>3},
        {"hour"=>"05", "views"=>3,  "people"=>0},
        {"hour"=>"04", "views"=>0,  "people"=>0},
        {"hour"=>"03", "views"=>1,  "people"=>1},
        {"hour"=>"02", "views"=>7,  "people"=>4},
        {"hour"=>"01", "views"=>3,  "people"=>3},
        {"hour"=>"00", "views"=>4,  "people"=>2},
        {"hour"=>"23", "views"=>15, "people"=>6},
        {"hour"=>"22", "views"=>7,  "people"=>5}
      ]

      gauge['recent_days'].should   == [
        {"views" => 53,  "date" => Date.new(2011, 11, 02), "people" => 29},
        {"views" => 137, "date" => Date.new(2011, 11, 01), "people" => 72},
        {"views" => 154, "date" => Date.new(2011, 10, 31), "people" => 108},
        {"views" => 70,  "date" => Date.new(2011, 10, 30), "people" => 39},
        {"views" => 310, "date" => Date.new(2011, 10, 29), "people" => 186},
        {"views" => 360, "date" => Date.new(2011, 10, 28), "people" => 233},
        {"views" => 16,  "date" => Date.new(2011, 10, 27), "people" => 11},
        {"views" => 17,  "date" => Date.new(2011, 10, 26), "people" => 12},
        {"views" => 19,  "date" => Date.new(2011, 10, 25), "people" => 13},
        {"views" => 10,  "date" => Date.new(2011, 10, 24), "people" => 9},
        {"views" => 2,   "date" => Date.new(2011, 10, 23), "people" => 2},
        {"views" => 6,   "date" => Date.new(2011, 10, 22), "people" => 6},
        {"views" => 19,  "date" => Date.new(2011, 10, 21), "people" => 11},
        {"views" => 65,  "date" => Date.new(2011, 10, 20), "people" => 49},
        {"views" => 13,  "date" => Date.new(2011, 10, 19), "people" => 11},
        {"views" => 8,   "date" => Date.new(2011, 10, 18), "people" => 5},
        {"views" => 22,  "date" => Date.new(2011, 10, 17), "people" => 18},
        {"views" => 24,  "date" => Date.new(2011, 10, 16), "people" => 16},
        {"views" => 133, "date" => Date.new(2011, 10, 15), "people" => 113},
        {"views" => 366, "date" => Date.new(2011, 10, 14), "people" => 335},
        {"views" => 27,  "date" => Date.new(2011, 10, 13), "people" => 19},
        {"views" => 19,  "date" => Date.new(2011, 10, 12), "people" => 13},
        {"views" => 17,  "date" => Date.new(2011, 10, 11), "people" => 9},
        {"views" => 80,  "date" => Date.new(2011, 10, 10), "people" => 46},
        {"views" => 33,  "date" => Date.new(2011, 10, 9), "people" => 8},
        {"views" => 20,  "date" => Date.new(2011, 10, 8), "people" => 9},
        {"views" => 29,  "date" => Date.new(2011, 10, 7), "people" => 16},
        {"views" => 143, "date" => Date.new(2011, 10, 6), "people" => 83},
        {"views" => 29,  "date" => Date.new(2011, 10, 5), "people" => 24},
        {"views" => 89,  "date" => Date.new(2011, 10, 4), "people" => 45}
      ]

      gauge['recent_months'].should == [
        {"views" => 190,  "date" => Date.new(2011, 11, 1), "people" => 82},
        {"views" => 2452, "date" => Date.new(2011, 10, 1), "people" => 1517},
        {"views" => 868,  "date" => Date.new(2011, 9, 1),  "people" => 488},
        {"views" => 562,  "date" => Date.new(2011, 8, 1),  "people" => 269},
        {"views" => 3287, "date" => Date.new(2011, 7, 1),  "people" => 2640},
        {"views" => 224,  "date" => Date.new(2011, 6, 1),  "people" => 133},
        {"views" => 143,  "date" => Date.new(2011, 5, 1),  "people" => 105},
        {"views" => 86,   "date" => Date.new(2011, 4, 1),  "people" => 52},
        {"views" => 367,  "date" => Date.new(2011, 3, 1),  "people" => 144},
        {"views" => 80,   "date" => Date.new(2011, 2, 1),  "people" => 44}
      ]
    end
  end

  describe "#create_gauge" do
    context "valid" do
      before do
        stub_post('https://secure.gaug.es/gauges', :gauge_create_valid)
        @client   = Gauges.new(:token => 'asdf')
        @response = @client.create_gauge({
          :title          => 'Example',
          :tz             => 'Eastern Time (US & Canada)'
        })
      end

      it "returns 201" do
        @response.code.should == 201
      end

      it "returns gauge" do
        @response['gauge']['title'].should         == 'Example'
        @response['gauge']['tz'].should            == 'Eastern Time (US & Canada)'
        @response['gauge']['id'].should            == '4eb1eaf5e5947c7408000001'
        @response['gauge']['creator_id'].should    == '4df37acbe5947cabdd000001'
        @response['gauge']['now_in_zone'].should   == Time.parse('Wed Nov 02 21:14:29 -0400 2011')
        @response['gauge']['enabled'].should       == true

        @response['gauge']['urls']["self"].should        == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001"
        @response['gauge']['urls']["shares"].should      == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/shares"
        @response['gauge']['urls']["referrers"].should   == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/referrers"
        @response['gauge']['urls']["technology"].should  == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/technology"
        @response['gauge']['urls']["content"].should     == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/content"
        @response['gauge']['urls']["locations"].should   == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/locations"
        @response['gauge']['urls']["engines"].should     == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/engines"
        @response['gauge']['urls']["terms"].should       == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/terms"
        @response['gauge']['urls']["resolutions"].should == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/resolutions"
        @response['gauge']['urls']["traffic"].should     == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/traffic"
      end
    end

    context "invalid" do
      before do
        stub_post('https://secure.gaug.es/gauges', :gauge_create_invalid)
        @client   = Gauges.new(:token => 'asdf')
        @response = @client.create_gauge({
          :title => 'Testing',
          :tz    => 'PooPoo'
        })
      end

      it "returns 422" do
        @response.code.should == 422
      end

      it "returns errors" do
        @response['errors'].should == {'tz' => 'is not included in the list'}
      end

      it "returns full messages" do
        @response['full_messages'].should == ['Tz is not included in the list']
      end
    end
  end

  describe "#gauge" do
    context "found" do
      before do
        stub_get('https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003', :gauge)
        @client   = Gauges.new(:token => 'asdf')
        @response = @client.gauge('4d597dfd6bb4ba2c48000003')
      end

      it "returns 200" do
        @response.code.should == 200
      end

      it "returns gauge" do
        @response['gauge']['title'].should         == 'acme.com'
        @response['gauge']['tz'].should            == 'Eastern Time (US & Canada)'
        @response['gauge']['id'].should            == '4d597dfd6bb4ba2c48000003'
        @response['gauge']['creator_id'].should    == '4df37acbe5947cabdd000001'
        @response['gauge']['now_in_zone'].should   == Time.parse('Wed Nov 02 21:16:06 -0400 2011')
        @response['gauge']['enabled'].should       == true

        @response['gauge']['urls']["self"].should        == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003"
        @response['gauge']['urls']["shares"].should      == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/shares"
        @response['gauge']['urls']["referrers"].should   == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/referrers"
        @response['gauge']['urls']["technology"].should  == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/technology"
        @response['gauge']['urls']["content"].should     == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/content"
        @response['gauge']['urls']["locations"].should   == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/locations"
        @response['gauge']['urls']["engines"].should     == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/engines"
        @response['gauge']['urls']["terms"].should       == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/terms"
        @response['gauge']['urls']["resolutions"].should == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/resolutions"
        @response['gauge']['urls']["traffic"].should     == "https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/traffic"
      end
    end

    context "not found" do
      before do
        stub_get('https://secure.gaug.es/gauges/1234', :gauge_not_found)
        @client   = Gauges.new(:token => 'asdf')
        @response = @client.gauge('1234')
      end

      it "returns 404" do
        @response.code.should == 404
      end

      it "returns message" do
        @response['message'].should == 'Not found'
        @response['status'].should  == 'fail'
      end
    end
  end

  describe "#update_gauge" do
    before do
      stub_put('https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001', :gauge_update)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.update_gauge('4eb1eaf5e5947c7408000001', :title => 'Testing')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns updated gauge" do
      @response['gauge']['title'].should         == 'New Title'
      @response['gauge']['tz'].should            == 'Eastern Time (US & Canada)'
      @response['gauge']['id'].should            == '4eb1eaf5e5947c7408000001'
      @response['gauge']['creator_id'].should    == '4df37acbe5947cabdd000001'
      @response['gauge']['now_in_zone'].should   == Time.parse('Wed Nov 02 21:18:12 -0400 2011')
      @response['gauge']['enabled'].should       == true

      @response['gauge']['urls']["self"].should        == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001"
      @response['gauge']['urls']["shares"].should      == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/shares"
      @response['gauge']['urls']["referrers"].should   == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/referrers"
      @response['gauge']['urls']["technology"].should  == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/technology"
      @response['gauge']['urls']["content"].should     == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/content"
      @response['gauge']['urls']["locations"].should   == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/locations"
      @response['gauge']['urls']["engines"].should     == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/engines"
      @response['gauge']['urls']["terms"].should       == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/terms"
      @response['gauge']['urls']["resolutions"].should == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/resolutions"
      @response['gauge']['urls']["traffic"].should     == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/traffic"
    end
  end

  describe "#delete_gauge" do
    before do
      stub_delete('https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001', :gauge_delete)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.delete_gauge('4eb1eaf5e5947c7408000001')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns gauge" do
      @response['gauge']['title'].should         == 'New Title'
      @response['gauge']['tz'].should            == 'Eastern Time (US & Canada)'
      @response['gauge']['id'].should            == '4eb1eaf5e5947c7408000001'
      @response['gauge']['creator_id'].should    == '4df37acbe5947cabdd000001'
      @response['gauge']['now_in_zone'].should   == Time.parse('Wed Nov 02 21:19:08 -0400 2011')
      @response['gauge']['enabled'].should       == true

      @response['gauge']['urls']["self"].should        == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001"
      @response['gauge']['urls']["shares"].should      == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/shares"
      @response['gauge']['urls']["referrers"].should   == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/referrers"
      @response['gauge']['urls']["technology"].should  == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/technology"
      @response['gauge']['urls']["content"].should     == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/content"
      @response['gauge']['urls']["locations"].should   == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/locations"
      @response['gauge']['urls']["engines"].should     == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/engines"
      @response['gauge']['urls']["terms"].should       == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/terms"
      @response['gauge']['urls']["resolutions"].should == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/resolutions"
      @response['gauge']['urls']["traffic"].should     == "https://secure.gaug.es/gauges/4eb1eaf5e5947c7408000001/traffic"
    end
  end

  describe "#shares" do
    before do
      stub_get('https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/shares', :shares)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.shares('4d597dfd6bb4ba2c48000003')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns a users hash" do
      @response.should be_an_instance_of(Hash)
      @response['shares'].length.should == 1
      share = @response['shares'].first
      share['name'].should            == "Joe "
      share['id'].should              == '4df37acbe5947cabdd000001'
      share['type'].should            == 'user'
      share['last_name'].should       == nil
      share['first_name'].should      == 'Joe'
      share['email'].should           == 'john@doe.com'
      share['urls']['remove'].should  == 'https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/shares/4df37acbe5947cabdd000001'
    end
  end

  describe "#share" do
    context "valid" do
      before do
        stub_post('https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/shares', :share_add_valid)
        @client   = Gauges.new(:token => 'asdf')
        @response = @client.share('4d597dfd6bb4ba2c48000003', {:email => 'greg@acme.com'})
      end

      it "returns 200" do
        @response.code.should == 200
      end

      it "returns hash with invites and users arrays" do
        @response.should be_an_instance_of(Hash)

        @response['share']['id'].should             == '4eb1ed03e5947c7408000002'
        @response['share']['name'].should           == 'jane@doe.com'
        @response['share']['type'].should           == 'invite'
        @response['share']['last_name'].should      == nil
        @response['share']['first_name'].should     == nil
        @response['share']['email'].should          == 'jane@doe.com'
        @response['share']['urls']['remove'].should == 'https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/shares/4eb1ed03e5947c7408000002'
      end
    end

    context "invalid" do
      before do
        stub_post('https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/shares', :share_add_invalid)
        @client   = Gauges.new(:token => 'asdf')
        @response = @client.share('4d597dfd6bb4ba2c48000003', {:email => 'greg@acme'})
      end

      it "returns 422" do
        @response.code.should == 422
      end

      it "returns hash errors and full_messages array" do
        @response.should be_an_instance_of(Hash)

        @response['errors'].should have_key('email')
        @response['errors']['email'].should == "does not appear to be legit"

        @response['full_messages'].size.should be(1)
        @response['full_messages'].first.should == "Email does not appear to be legit"
      end
    end
  end

  describe "#unshare" do
    before do
      stub_delete('https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/shares/4eb1ed03e5947c7408000002', :share_remove)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.unshare('4d597dfd6bb4ba2c48000003', '4eb1ed03e5947c7408000002')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns hash with invites and users arrays" do
      @response.should be_an_instance_of(Hash)

      @response['share']['id'].should             == '4eb1ed03e5947c7408000002'
      @response['share']['name'].should           == 'jane@doe.com'
      @response['share']['type'].should           == 'invite'
      @response['share']['last_name'].should      == nil
      @response['share']['first_name'].should     == nil
      @response['share']['email'].should          == 'jane@doe.com'
      @response['share']['urls']['remove'].should == 'https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/shares/4eb1ed03e5947c7408000002'
    end
  end

  describe "#content" do
    before do
      stub_get('https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/content', :content)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.content('4d597dfd6bb4ba2c48000003')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns a hash with content as the primary key" do
      @response.should be_an_instance_of(Hash)
      @response['content'].size.should be(8)

      item = @response['content'].first
      item['title'].should == 'HipChat, hubot, and Me // acme.com'
      item['views'].should == 31
      item['path'].should  == '/blog/archives/2011/10/28/hipchat-hubot-and-me/'
      item['host'].should  == 'acme.com'

      @response['urls']['older'].should         == 'https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/content?date=2011-11-01'
      @response['urls']['newer'].should         == nil
      @response['urls']['previous_page'].should == nil
      @response['urls']['next_page'].should     == nil
    end
  end

  describe "#referrers" do
    before do
      stub_get('https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/referrers', :referrers)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.referrers('4d597dfd6bb4ba2c48000003')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns a hash with referrers as the primary key" do
      @response.should be_an_instance_of(Hash)
      @response['referrers'].size.should be(2)

      item = @response['referrers'].first
      item['url'].should == 'http://martinciu.com/2011/11/deploying-hubot-to-heroku-like-a-boss.html'
      item['views'].should == 1
      item['path'].should  == '/2011/11/deploying-hubot-to-heroku-like-a-boss.html'
      item['host'].should  == 'martinciu.com'

      @response['urls']['older'].should         == 'https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/referrers?date=2011-11-01'
      @response['urls']['newer'].should         == nil
      @response['urls']['previous_page'].should == nil
      @response['urls']['next_page'].should     == nil

    end
  end

  describe "#traffic" do
    before do
      stub_get('https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/traffic', :traffic)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.traffic('4d597dfd6bb4ba2c48000003')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns a hash with traffic as the primary key" do
      @response.should be_an_instance_of(Hash)
      @response['traffic'].size.should be(2)

      item = @response['traffic'].first
      item['date'].should   == Date.parse('2011-11-1')
      item['views'].should  == 137
      item['people'].should == 72

      @response['urls']['older'].should         == 'https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/traffic?date=2011-10-01'
      @response['urls']['newer'].should         == nil
      @response['urls']['previous_page'].should == nil
      @response['urls']['next_page'].should     == nil

    end
  end

  describe "#resolutions" do
    before do
      stub_get('https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/resolutions', :resolutions)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.resolutions('4d597dfd6bb4ba2c48000003')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns a hash with browser_heights, browser_widths, and screen_widths" do
      @response.should be_an_instance_of(Hash)
      @response['browser_heights'].size.should be(5)
      @response['browser_widths'].size.should be(8)
      @response['screen_widths'].size.should be(8)

      browser_height = @response['browser_heights'].first
      browser_height['title'].should == '600'
      browser_height['views'].should == 69

      browser_width = @response['browser_widths'].first
      browser_width['title'].should == '1280'
      browser_width['views'].should == 56

      screen_width = @response['screen_widths'].first
      screen_width['title'].should == '1600'
      screen_width['views'].should == 58

      @response['urls']['older'].should         == 'https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/resolutions?date=2011-10-01'
      @response['urls']['newer'].should         == nil
      @response['urls']['previous_page'].should == nil
      @response['urls']['next_page'].should     == nil
    end
  end

  describe "#technology" do
    before do
      stub_get('https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/technology', :technology)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.technology('4d597dfd6bb4ba2c48000003')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns a hash with browsers and platforms" do
      @response.should be_an_instance_of(Hash)
      @response['browsers'].size.should be(6)
      @response['platforms'].size.should be(6)

      browser = @response['browsers'].first
      browser['title'].should == 'Chrome'
      browser['views'].should == 135
      browser['versions'].first['title'].should == "15.0"
      browser['versions'].first['views'].should == 95

      platform = @response['platforms'].first
      platform['title'].should == 'Macintosh'
      platform['views'].should == 142
      platform['key'].should   == 'macintosh'

      @response['urls']['older'].should         == 'https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/technology?date=2011-10-01'
      @response['urls']['newer'].should         == nil
      @response['urls']['previous_page'].should == nil
      @response['urls']['next_page'].should     == nil
    end
  end

  describe "#terms" do
    before do
      stub_get('https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/terms', :terms)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.terms('4d597dfd6bb4ba2c48000003')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns a hash with terms as the primary key" do
      @response.should be_an_instance_of(Hash)
      @response['terms'].size.should be(41)

      item = @response['terms'][2]
      item['term'].should == 'hipchat hubot'
      item['views'].should == 5

      @response['urls']['older'].should         == 'https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/terms?date=2011-10-01'
      @response['urls']['newer'].should         == nil
      @response['urls']['previous_page'].should == nil
      @response['urls']['next_page'].should     == nil
    end
  end

  describe "#engines" do
    before do
      stub_get('https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/engines', :engines)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.engines('4d597dfd6bb4ba2c48000003')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns a hash with engines as the primary key" do
      @response.should be_an_instance_of(Hash)
      @response['engines'].size.should be(1)

      item = @response['engines'].first
      item['title'].should == 'Google'
      item['views'].should == 90
      item['key'].should   == 'google'

      @response['urls']['older'].should         == 'https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/engines?date=2011-10-01'
      @response['urls']['newer'].should         == nil
      @response['urls']['previous_page'].should == nil
      @response['urls']['next_page'].should     == nil
    end
  end

  describe "#locations" do
    before do
      stub_get('https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/locations', :locations)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.locations('4d597dfd6bb4ba2c48000003')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns a hash with locations as the primary key" do
      @response.should be_an_instance_of(Hash)
      @response['locations'].size.should be(23)

      item = @response['locations'].first
      item['key'].should == 'US'
      item['regions'].first['title'].should == 'California'
      item['regions'].first['views'].should == 22
      item['regions'].first['key'].should   == 'CA'

      @response['urls']['older'].should         == 'https://secure.gaug.es/gauges/4d597dfd6bb4ba2c48000003/locations?date=2011-10-01'
      @response['urls']['newer'].should         == nil
      @response['urls']['previous_page'].should == nil
      @response['urls']['next_page'].should     == nil
    end
  end
end