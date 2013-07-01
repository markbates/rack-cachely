require 'spec_helper'

describe Rack::Cachely::Context do

  describe 'call' do

    let(:app) { mock }
    let(:context) { Rack::Cachely::Context.new(app) }

    context 'when cachely is disabled in config' do
      before do
        Rack::Cachely.config.enabled = false
      end

      it 'invokes the app' do
        app.should_receive(:call)
        context.call({})
      end

    end

    context 'with cachely enabled in config' do
      before do
        Rack::Cachely.config.enabled = true
        @env = { 'rack-cachely.perform_caching' => true }
        Rack::Cachely::Store.stub(get: true)
      end

      context 'without no-cachely param' do
        before do
          context.stub(:request => mock(:request_method => 'GET', :params => {}))
        end

        it 'does not invoke the app' do
          app.should_not_receive(:call)
          context.call(@env)
        end
      end

      context 'with no-cachely param' do
        before do
          context.stub(:request => mock(:request_method => 'GET', :params => {'no-cachely' => true}))
        end

        it 'invokes the app' do
          app.should_receive(:call)
          context.call(@env)
        end
      end
    end

  end

end
