require 'spec_helper'

describe Rack::Attack::RateLimit do

  include Rack::Test::Methods

  let(:throttle) { 'rack_attack_throttle' }

  let(:app) do
    use_throttle = throttle
    Rack::Builder.new {
      use Rack::Attack::RateLimit, throttle: use_throttle
      run lambda { |env| [200, {}, 'Hello, World!'] }
    }.to_app

  end

  context 'Throttle data not present from Rack::Attack' do

    before(:each) do
      get '/'
    end

    it 'should not create Rate-Limit headers' do
      last_response.header.key?('X-Rate-Limit-Limit').should be false
      last_response.header.key?('X-Rate-Limit-Remaining').should be false
      last_response.header.key?('X-Rate-Limit-Period').should be false
    end

  end

  context 'Throttle data present from Rack::Attack' do

    let(:request_limit) { (1..10000).to_a.sample }
    let(:request_count) { (1..(request_limit-10)).to_a.sample }

    let(:rack_attack_throttle_data) do
      { "#{throttle}" => { count: request_count, limit: request_limit, period: 60 } }
    end

    before(:each) do
      get "/", {}, { "#{Rack::Attack::RateLimit::RACK_ATTACK_KEY}" => rack_attack_throttle_data }
    end

    it 'should include Rate-Limit headers' do
      p last_response.header
      last_response.header.key?('X-Rate-Limit-Limit').should be true
      last_response.header.key?('X-Rate-Limit-Remaining').should be true
      last_response.header.key?('X-Rate-Limit-Period').should be true
    end

    it 'should return correct rate limit in header' do
      last_response.header['X-Rate-Limit-Limit'].to_i.should eq request_limit
    end

    it 'should return correct remaining calls in header' do
      last_response.header['X-Rate-Limit-Remaining'].to_i.should eq (request_limit-request_count)
    end

    it 'should return correct period in header' do
      last_response.header['X-Rate-Limit-Period'].to_i.should eq 60
    end
  end

end
