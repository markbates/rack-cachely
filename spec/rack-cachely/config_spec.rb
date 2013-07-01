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


  describe "initializer" do

    it "sets cachely_url from ENV" do
      config.cachely_url.should == "#{ENV['CACHELY_URL']}/v1/cache"
    end

    it "sets enabled" do
      config.enabled.should == true
    end

    context "with no ENV['CACHELY_URL']" do

      before do
        @old_env = ENV.delete('CACHELY_URL')
        @logger = mock
        Rack::Cachely::Config.any_instance.stub(:logger).and_return @logger
      end

      after do
        ENV['CACHELY_URL'] = @old_env
      end

      it "warns and disables if there is no cachely_url" do
        @logger.should_receive(:warn)
        config.enabled.should == false
      end

    end

  end


end
