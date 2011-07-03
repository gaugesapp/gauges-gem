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

  describe "#clients" do
    before do
      stub_get('http://john%40orderedlist.com:foobar@api.gaug.es/clients', :clients)
      @client  = Gauges.new(:email => 'john@orderedlist.com', :password => 'foobar')
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
      @client = Gauges.new(:email => 'john@orderedlist.com', :password => 'foobar')
      @response = @client.create_client(:description => 'HipChat')
    end

    it "returns created client" do
      @response.should be_instance_of(Hash)

      @response['key'].should         == 'asdf'
      @response['description'].should == 'HipChat'
      @response['created_at'].should  == Time.utc(2011, 7, 3, 15, 38, 28)
    end
  end
end