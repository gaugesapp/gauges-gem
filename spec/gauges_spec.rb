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
end