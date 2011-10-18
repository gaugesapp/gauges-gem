require 'helper'

describe Gauges do
  context "initializing with email and password" do
    before do
      @client = Gauges.new(:email => 'john@orderedlist.com', :password => 'foobar')
    end

    it "sets email" do
      @client.email.should == 'john@orderedlist.com'
    end

    it "sets password" do
      @client.password.should == 'foobar'
    end

    it "knows it is using http auth" do
      @client.basic_auth?.should be_true
    end

    it "knows it is not using token" do
      @client.header_auth?.should be_false
    end
  end

  context "initializing with token" do
    before do
      @client = Gauges.new(:token => 'asdf')
    end

    it "sets token" do
      @client.token.should == 'asdf'
    end

    it "knows it is using token" do
      @client.header_auth?.should be_true
    end

    it "knows it is not using http auth" do
      @client.basic_auth?.should be_false
    end
  end

  context "http auth failure" do
    before do
      stub_get('http://api.gaug.es/clients', :clients_http_auth_failure)
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
      stub_get('http://api.gaug.es/me', :me)
      @client = Gauges.new(:token => 'asdf')
    end

    it "sets token header for request" do
      Gauges.should_receive(:get).with('/me', :headers => {
        'X-Gauges-Token' => 'asdf'
      }, :query => {})
      @client.me
    end
  end

  context "making request with basic auth" do
    before do
      stub_get('http://api.gaug.es/me', :me)
      @client = Gauges.new(:email => 'john@orderedlist.com', :password => 'foobar')
    end

    it "sets basic auth option" do
      Gauges.should_receive(:get).with('/me', :basic_auth => {
        :username => 'john@orderedlist.com',
        :password => 'foobar',
      }, :query => {})
      @client.me
    end
  end

  describe "#me" do
    before do
      stub_get('http://api.gaug.es/me', :me)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.me
    end

    it "returns my own information" do
      @response['user']['id'].should          == '4e109addbcd1b358f2000001'
      @response['user']['name'].should        == 'John Nunemaker'
      @response['user']['email'].should       == 'john@orderedlist.com'
      @response['user']['first_name'].should  == 'John'
      @response['user']['last_name'].should   == 'Nunemaker'
      @response['user']['gauges'].should == [
        {'id' => '4e109b34bcd1b358f2000003', 'owner' => true},
        {'id' => '4e109b33bcd1b358f2000002'},
      ]
    end
  end

  describe "#clients" do
    before do
      stub_get('http://api.gaug.es/clients', :clients)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.clients
    end

    it "returns an array of clients" do
      @response.should be_instance_of(Hash)
      @response['clients'].size.should be(1)

      client = @response['clients'].first
      client['key'].should          == 'asdf'
      client['created_at'].should   == Time.utc(2011, 7, 3, 15, 38, 28)
      client['description'].should  == 'HipChat'
    end
  end

  describe "#create_client" do
    before do
      stub_post('http://api.gaug.es/clients', :client_create)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.create_client(:description => 'HipChat')
    end

    it "returns 201" do
      @response.code.should == 201
    end

    it "returns created client" do
      @response.should be_instance_of(Hash)

      @response['client']['key'].should         == 'asdf'
      @response['client']['description'].should == 'HipChat'
      @response['client']['created_at'].should  == Time.utc(2011, 7, 3, 15, 38, 28)
    end
  end

  describe "#delete_client" do
    before do
      stub_delete('http://api.gaug.es/clients/acb5a1d9dcf209a3a382da61b860278f', :client_delete)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.delete_client('acb5a1d9dcf209a3a382da61b860278f')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns client" do
      @response['client']['key'].should         == 'acb5a1d9dcf209a3a382da61b860278f'
      @response['client']['description'].should == 'Testing'
      @response['client']['created_at'].should  == Time.parse('2011-08-16T16:31:23Z')
    end
  end

  describe "#update_me" do
    context "valid" do
      before do
        stub_put('http://api.gaug.es/me', :me_update)
        @client = Gauges.new(:token => 'asdf')
        @response = @client.update_me(:first_name => 'Frank', :last_name => 'Furter')
      end

      it "returns 200" do
        @response.code.should == 200
      end

      it "returns update user" do
        @response.should be_instance_of(Hash)
        @response['user']['id'].should          == '4e038e0dbcd1b32016000002'
        @response['user']['name'].should        == 'John Nunemaker'
        @response['user']['first_name'].should  == 'John'
        @response['user']['last_name'].should   == 'Nunemaker'
        @response['user']['email'].should       == 'john@orderedlist.com'
        @response['user']['gauges'].should      == [
          {'id' => '4e038e0ebcd1b32016000007'},
          {'id' => '4e0902b3bcd1b379ec000001', 'owner' => true},
        ]
      end
    end

    context "invalid" do
      before do
        stub_put('http://api.gaug.es/me', :me_update_invalid)
        @client   = Gauges.new(:token => 'asdf')
        @response = @client.update_me(:email => 'asdf')
      end

      it "returns 422" do
        @response.code.should == 422
      end

      it "returns errors" do
        @response['errors']['email'].should == 'does not appear to be legit'
      end

      it "returns full messages" do
        @response['full_messages'].should   == ['Email does not appear to be legit']
      end
    end
  end

  describe "#gauges" do
    before do
      stub_get('http://api.gaug.es/gauges', :gauges)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.gauges
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns array" do
      @response.should be_instance_of(Hash)
    end

    it "returns gauges" do
      gauge = @response['gauges'][0]

      gauge['title'].should         == 'RailsTips'
      gauge['service_value'].should == 'railstips.org'
      gauge['tz'].should            == 'Eastern Time (US & Canada)'
      gauge['id'].should            == '4d5f4992089bb618a2000005'
      gauge['creator_id'].should    == '4d58a6800184f6792e000001'
      gauge['now_in_zone'].should   == Time.parse('Tue Jul 05 10:40:14 -0400 2011')
      gauge['enabled'].should       == true
      gauge['recent_months'].should == [
        {"views" => 4324,  "date" => "2011-07", "people" => 2103},
        {"views" => 42613, "date" => "2011-06", "people" => 22766},
        {"views" => 39540, "date" => "2011-05", "people" => 19561},
        {"views" => 37741, "date" => "2011-04", "people" => 17632},
        {"views" => 59252, "date" => "2011-03", "people" => 28867},
        {"views" => 19039, "date" => "2011-02", "people" => 10406},
      ]
      gauge['all_time'].should      == {"views" => 202509, "people" => 96293}
      gauge['today'].should         == {"views" => 551,  "date" => Date.new(2011, 7, 5), "people" => 379}
      gauge['yesterday'].should     == {"views" => 1156, "date" => Date.new(2011, 7, 4), "people" => 724}
      gauge['recent_hours'].should  == [
        {"hour" => "10", "views" => 64, "people" => 56},
        {"hour" => "09", "views" => 68, "people" => 57},
        {"hour" => "08", "views" => 60, "people" => 45},
        {"hour" => "07", "views" => 34, "people" => 31},
        {"hour" => "06", "views" => 45, "people" => 39},
        {"hour" => "05", "views" => 55, "people" => 43},
        {"hour" => "04", "views" => 52, "people" => 45},
        {"hour" => "03", "views" => 51, "people" => 38},
        {"hour" => "02", "views" => 46, "people" => 35},
        {"hour" => "01", "views" => 37, "people" => 32},
        {"hour" => "00", "views" => 39, "people" => 25},
        {"hour" => "23", "views" => 38, "people" => 29},
        {"hour" => "22", "views" => 44, "people" => 26},
        {"hour" => "21", "views" => 27, "people" => 25},
        {"hour" => "20", "views" => 32, "people" => 21},
        {"hour" => "19", "views" => 41, "people" => 21},
        {"hour" => "18", "views" => 33, "people" => 22},
        {"hour" => "17", "views" => 54, "people" => 31},
        {"hour" => "16", "views" => 43, "people" => 34},
        {"hour" => "15", "views" => 45, "people" => 36},
        {"hour" => "14", "views" => 65, "people" => 50},
        {"hour" => "13", "views" => 67, "people" => 46},
        {"hour" => "12", "views" => 51, "people" => 32},
        {"hour" => "11", "views" => 77, "people" => 52},
      ]
      gauge['recent_days'].should   == [
        {"views" => 551,  "date" => Date.new(2011, 7, 5),  "people" => 379},
        {"views" => 1156, "date" => Date.new(2011, 7, 4),  "people" => 724},
        {"views" => 731,  "date" => Date.new(2011, 7, 3),  "people" => 465},
        {"views" => 660,  "date" => Date.new(2011, 7, 2),  "people" => 412},
        {"views" => 1226, "date" => Date.new(2011, 7, 1),  "people" => 780},
        {"views" => 1350, "date" => Date.new(2011, 6, 30), "people" => 908},
        {"views" => 1589, "date" => Date.new(2011, 6, 29), "people" => 1058},
        {"views" => 2134, "date" => Date.new(2011, 6, 28), "people" => 1487},
        {"views" => 1545, "date" => Date.new(2011, 6, 27), "people" => 1067},
        {"views" => 922,  "date" => Date.new(2011, 6, 26), "people" => 590},
        {"views" => 801,  "date" => Date.new(2011, 6, 25), "people" => 514},
        {"views" => 1375, "date" => Date.new(2011, 6, 24), "people" => 905},
        {"views" => 1964, "date" => Date.new(2011, 6, 23), "people" => 1273},
        {"views" => 5188, "date" => Date.new(2011, 6, 22), "people" => 3879},
        {"views" => 1464, "date" => Date.new(2011, 6, 21), "people" => 1030},
        {"views" => 1414, "date" => Date.new(2011, 6, 20), "people" => 989},
        {"views" => 821,  "date" => Date.new(2011, 6, 19), "people" => 510},
        {"views" => 920,  "date" => Date.new(2011, 6, 18), "people" => 562},
        {"views" => 1484, "date" => Date.new(2011, 6, 17), "people" => 849},
        {"views" => 1330, "date" => Date.new(2011, 6, 16), "people" => 902},
        {"views" => 1431, "date" => Date.new(2011, 6, 15), "people" => 928},
        {"views" => 1780, "date" => Date.new(2011, 6, 14), "people" => 1000},
        {"views" => 1279, "date" => Date.new(2011, 6, 13), "people" => 907},
        {"views" => 806,  "date" => Date.new(2011, 6, 12), "people" => 498},
        {"views" => 642,  "date" => Date.new(2011, 6, 11), "people" => 436},
        {"views" => 1161, "date" => Date.new(2011, 6, 10), "people" => 771},
        {"views" => 1463, "date" => Date.new(2011, 6, 9),  "people" => 904},
        {"views" => 1440, "date" => Date.new(2011, 6, 8),  "people" => 976},
        {"views" => 1354, "date" => Date.new(2011, 6, 7),  "people" => 886},
        {"views" => 1327, "date" => Date.new(2011, 6, 6),  "people" => 909},
      ]
    end
  end

  describe "#create_gauge" do
    context "valid" do
      before do
        stub_post('http://api.gaug.es/gauges', :gauge_create_valid)
        @client   = Gauges.new(:token => 'asdf')
        @response = @client.create_gauge({
          :title          => 'Testing',
          :service_value  => 'testing.com',
          :tz             => 'Eastern Time (US & Canada)'
        })
      end

      it "returns 201" do
        @response.code.should == 201
      end

      it "returns gauge" do
        @response['gauge']['title'].should         == 'Testing'
        @response['gauge']['service_value'].should == 'testing.com'
        @response['gauge']['tz'].should            == 'Eastern Time (US & Canada)'
        @response['gauge']['id'].should            == '4e4aa0f84c114f25c1000004'
        @response['gauge']['creator_id'].should    == '4e485b734c114f083c000001'
        @response['gauge']['now_in_zone'].should   == Time.parse('2011-08-16T12:55:20-04:00')
        @response['gauge']['enabled'].should       == true
      end
    end

    context "invalid" do
      before do
        stub_post('http://api.gaug.es/gauges', :gauge_create_invalid)
        @client   = Gauges.new(:token => 'asdf')
        @response = @client.create_gauge({
          :title          => 'Testing',
          :service_value  => 'testing.com',
          :tz             => 'PooPoo'
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
        stub_get('http://api.gaug.es/gauges/4e4aa0f84c114f25c1000004', :gauge)
        @client   = Gauges.new(:token => 'asdf')
        @response = @client.gauge('4e4aa0f84c114f25c1000004')
      end

      it "returns 200" do
        @response.code.should == 200
      end

      it "returns gauge" do
        @response['gauge']['title'].should         == 'Testing'
        @response['gauge']['service_value'].should == 'testing.com'
        @response['gauge']['tz'].should            == 'Eastern Time (US & Canada)'
        @response['gauge']['id'].should            == '4e4aa0f84c114f25c1000004'
        @response['gauge']['creator_id'].should    == '4e485b734c114f083c000001'
        @response['gauge']['now_in_zone'].should   == Time.parse('2011-08-16T12:55:20-04:00')
        @response['gauge']['enabled'].should       == true
      end
    end

    context "not found" do
      before do
        stub_get('http://api.gaug.es/gauges/1234', :gauge_not_found)
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
      stub_put('http://api.gaug.es/gauges/4e4ab1674c114f2cb7000008', :gauge_update)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.update_gauge('4e4ab1674c114f2cb7000008', :title => 'Testing')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns updated gauge" do
      @response['gauge']['title'].should         == 'Testing'
      @response['gauge']['service_value'].should == 'testing.com'
      @response['gauge']['tz'].should            == 'Eastern Time (US & Canada)'
      @response['gauge']['id'].should            == '4e4ab1674c114f2cb7000008'
      @response['gauge']['creator_id'].should    == '4e485b734c114f083c000001'
      @response['gauge']['now_in_zone'].should   == Time.parse('2011-08-16T14:13:34-04:00')
      @response['gauge']['enabled'].should       == true
    end
  end

  describe "#delete_gauge" do
    before do
      stub_delete('http://api.gaug.es/gauges/4e4aa0f84c114f25c1000004', :gauge_delete)
      @client   = Gauges.new(:token => 'asdf')
      @response = @client.delete_gauge('4e4aa0f84c114f25c1000004')
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns gauge" do
      @response['gauge']['title'].should         == 'Testing'
      @response['gauge']['service_value'].should == 'testing.com'
      @response['gauge']['tz'].should            == 'Eastern Time (US & Canada)'
      @response['gauge']['id'].should            == '4e4aa0f84c114f25c1000004'
      @response['gauge']['creator_id'].should    == '4e485b734c114f083c000001'
      @response['gauge']['now_in_zone'].should   == Time.parse('2011-08-16T13:56:32-04:00')
      @response['gauge']['enabled'].should       == true
    end
  end
end