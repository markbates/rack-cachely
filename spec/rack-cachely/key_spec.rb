require 'spec_helper'

describe Rack::Cachely::Key do

  let(:key) { Rack::Cachely::Key.new(request) }

  describe "generate" do
  
    let(:request) { double(scheme: "http", host: "example.com", port: 80, script_name: "/foo", path_info: "/bar", query_string: "b=B&a=A&d=D&c=C") }

    it "returns a uniformed url" do
      key.to_s.should eql("http://example.com/foo/bar?a=A&b=B&c=C&d=D")
    end

    it "will ignore certain query params" do
      Rack::Cachely.config.ignore_query_params = ["A", "c"]
      key.to_s.should eql("http://example.com/foo/bar?b=B&d=D")
    end

    context "no query string" do
      
      let(:request) { double(scheme: "http", host: "example.com", port: 80, script_name: "/foo", path_info: "/bar", query_string: "") }

      it "does not have an empty ? at the end" do
        key.to_s.should eql("http://example.com/foo/bar")
      end

    end
  
  end

end