require 'spec_helper'

describe Rack::Cachely::Key do

  let(:key) { Rack::Cachely::Key.new(request) }

  describe "generate" do
  
    let(:request) { double(scheme: "http", host: "example.com", port: 80, script_name: "/foo", path_info: "/bar", query_string: "b=B&a=A") }

    it "returns a uniformed url" do
      key.to_s.should eql("http://example.com/foo/bar?a=A&b=B")
    end
  
  end

end