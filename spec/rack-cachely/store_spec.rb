require "spec_helper"

describe Rack::Cachely::Store do

  let(:key) { "http://example.com" }
  let(:store) { Rack::Cachely::Store }

  describe "get" do
  
    it "retreives a page from the service" do
      response_mock = double(code: "200", body: "hello!")
      response_mock.stub!(:each_header).and_yield("Content-Type", "text/html")
      Net::HTTP::Get.should_receive(:new).with("/v1/cache?_version=#{Rack::Cachely::VERSION}&url=http%3A%2F%2Fexample.com").and_return {
        m = double
        m.should_receive(:basic_auth).with("1234567890", nil)
        m
      }
      Net::HTTP.should_receive(:new).with("www.cachelyapp.com", 80).and_return(double(request: response_mock))

      res = store.get(key)
      res[0].should eql(200)
      res[1].should eql("Content-Type" => "text/html")
      res[2].read.should eql("hello!")
    end

    it "returns nil if no page is found" do
      Net::HTTP.stub!(:get_response).and_return(double(code: "404"))

      store.get(key).should be_nil
    end

    it "rescues from a timeout" do
      Net::HTTP.stub!(:get_response).and_raise(Timeout::Error)
      expect {
        store.get(key).should be_nil
      }.to_not raise_error(Timeout::Error)
    end

  end

  describe "post" do

    let(:rack) { [200, {"Content-Type" => "text/html"}, "hello!"] }
    let(:data) do
      {
        "document[url]" => "http://example.com", 
        "document[status]" => 200, 
        "document[body]" => "hello!", 
        "document[age]" => 30, 
        "document[headers][Content-Type]" => "text/html",
        "_version" => Rack::Cachely::VERSION
      }
    end
    
    context "pure string" do
      
      it "adds a page to the service" do
        Net::HTTP.should_receive(:post_form).with(URI(Rack::Cachely.config.cachely_url), data)

        store.post(key, rack, age: 30)
      end

    end

    context "with .body" do

      it "adds a page to the service" do
        rack[2] = double(body: "hello!")
        Net::HTTP.should_receive(:post_form).with(URI(Rack::Cachely.config.cachely_url), data)

        store.post(key, rack, age: 30)
      end  

    end

    it "rescues from a timeout" do
      Net::HTTP.stub!(:post_form).and_raise(Timeout::Error)
      expect {
        store.post(key, rack, age: 30)
      }.to_not raise_error(Timeout::Error)
    end

  end

end
