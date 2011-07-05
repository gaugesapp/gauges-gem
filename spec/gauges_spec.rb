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
  end

  context "http auth failure" do
    before do
      stub_get('http://john%40orderedlist.com:foobar@api.gaug.es/clients', :clients_http_auth_failure)
      @client   = Gauges.new(:email => 'john@orderedlist.com', :password => 'foobar')
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

  describe "#me" do
    before do
      stub_get('http://john%40orderedlist.com:foobar@api.gaug.es/me', :me)
      @client   = Gauges.new(:email => 'john@orderedlist.com', :password => 'foobar')
      @response = @client.me
    end

    it "returns my own information" do
      @response['id'].should          == '4e109addbcd1b358f2000001'
      @response['name'].should        == 'John Nunemaker'
      @response['email'].should       == 'john@orderedlist.com'
      @response['first_name'].should  == 'John'
      @response['last_name'].should   == 'Nunemaker'
      @response['sites'].should == [
        {'id' => '4e109b34bcd1b358f2000003', 'owner' => true},
        {'id' => '4e109b33bcd1b358f2000002'},
      ]
    end
  end

  describe "#clients" do
    before do
      stub_get('http://john%40orderedlist.com:foobar@api.gaug.es/clients', :clients)
      @client   = Gauges.new(:email => 'john@orderedlist.com', :password => 'foobar')
      @response = @client.clients
    end

    it "returns an array of clients" do
      @response.should be_instance_of(Array)
      @response.size.should be(1)

      client = @response.first
      client['key'].should          == 'asdf'
      client['created_at'].should   == Time.utc(2011, 7, 3, 15, 38, 28)
      client['description'].should  == 'HipChat'
    end
  end

  describe "#create_client" do
    before do
      stub_post('http://john%40orderedlist.com:foobar@api.gaug.es/clients', :client_create)
      @client   = Gauges.new(:email => 'john@orderedlist.com', :password => 'foobar')
      @response = @client.create_client(:description => 'HipChat')
    end

    it "returns 201" do
      @response.code.should == 201
    end

    it "returns created client" do
      @response.should be_instance_of(Hash)

      @response['key'].should         == 'asdf'
      @response['description'].should == 'HipChat'
      @response['created_at'].should  == Time.utc(2011, 7, 3, 15, 38, 28)
    end
  end

  describe "#update_me" do
    context "valid" do
      before do
        stub_put('http://john%40orderedlist.com:foobar@api.gaug.es/me', :me_update)
        @client = Gauges.new(:email => 'john@orderedlist.com', :password => 'foobar')
        @response = @client.update_me(:first_name => 'Frank', :last_name => 'Furter')
      end

      it "returns 200" do
        @response.code.should == 200
      end

      it "returns update user" do
        @response.should be_instance_of(Hash)
        @response['id'].should          == '4e038e0dbcd1b32016000002'
        @response['name'].should        == 'John Nunemaker'
        @response['first_name'].should  == 'John'
        @response['last_name'].should   == 'Nunemaker'
        @response['email'].should       == 'john@orderedlist.com'
        @response['sites'].should       == [
          {'id' => '4e038e0ebcd1b32016000007'},
          {'id' => '4e0902b3bcd1b379ec000001', 'owner' => true},
        ]
      end
    end

    context "invalid" do
      before do
        stub_put('http://john%40orderedlist.com:foobar@api.gaug.es/me', :me_update_invalid)
        @client   = Gauges.new(:email => 'john@orderedlist.com', :password => 'foobar')
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

  describe "#sites" do
    before do
      stub_get('http://john%40orderedlist.com:foobar@api.gaug.es/sites', :sites)
      @client   = Gauges.new(:email => 'john@orderedlist.com', :password => 'foobar')
      @response = @client.sites
    end

    it "returns 200" do
      @response.code.should == 200
    end

    it "returns array" do
      @response.should be_instance_of(Array)
    end

    it "returns sites" do
      site = @response[0]

      site['title'].should         == 'RailsTips'
      site['service_value'].should == 'railstips.org'
      site['tz'].should            == 'Eastern Time (US & Canada)'
      site['id'].should            == '4d5f4992089bb618a2000005'
      site['creator_id'].should    == '4d58a6800184f6792e000001'
      site['now_in_zone'].should   == Time.parse('Tue Jul 05 10:40:14 -0400 2011')
      site['enabled'].should       == true
      site['recent_months'].should == [
        {"views" => 4324,  "date" => "2011-07", "people" => 2103},
        {"views" => 42613, "date" => "2011-06", "people" => 22766},
        {"views" => 39540, "date" => "2011-05", "people" => 19561},
        {"views" => 37741, "date" => "2011-04", "people" => 17632},
        {"views" => 59252, "date" => "2011-03", "people" => 28867},
        {"views" => 19039, "date" => "2011-02", "people" => 10406},
      ]
      site['all_time'].should      == {"views" => 202509, "people" => 96293}
      site['today'].should         == {"views" => 551,  "date" => Date.new(2011, 7, 5), "people" => 379}
      site['yesterday'].should     == {"views" => 1156, "date" => Date.new(2011, 7, 4), "people" => 724}
      site['recent_hours'].should  == [
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
      site['recent_days'].should   == [
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
end