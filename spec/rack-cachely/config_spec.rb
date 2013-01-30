require 'spec_helper'

describe Rack::Cachely::Config do

  let(:config) { Rack::Cachely::Config.new(foo: 'bar') }

  describe "method_missing" do
  
    it "returns a value from the options" do
      config.foo.should eql("bar")
    end

    it "returns nil if there is no value" do
      config.bar.should be_nil
    end

    it "sets a value into the options" do
      config.foo = 'FOO'
      config.foo.should eql("FOO")
    end
  
  end

end