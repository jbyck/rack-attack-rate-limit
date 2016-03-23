require 'spec_helper'

describe Rack::Attack::RateLimit do

  include Rack::Test::Methods

  let(:throttle_one)    { 'foo_throttle' }
  let(:throttle_two)    { 'bar_throttle' }
  let(:throttle_three)  { 'baz_throttle' }

  let(:app) do
    use_throttle = throttle_one
    Rack::Builder.new do
      use Rack::Attack::RateLimit, throttle: use_throttle
      run ->(_env) { [200, {}, 'Hello, World!'] }
    end.to_app
  end

  context 'Throttle data not present from Rack::Attack' do

    before(:each) do
      get '/'
    end

    it 'should not create RateLimit headers' do
      last_response.header.key?('X-RateLimit-Limit').should be false
      last_response.header.key?('X-RateLimit-Remaining').should be false
      last_response.header.key?('X-RateLimit-Reset').should be false
    end

  end

  context 'Throttle data present from Rack::Attack' do
    before(:each) do
      get '/', {}, "#{Rack::Attack::RateLimit::RACK_ATTACK_KEY}" => rack_attack_throttle_data
    end

    let(:request_limit) { (1..10_000).to_a.sample }
    let(:request_count) { (1..(request_limit - 10)).to_a.sample }
    let(:request_period) { rand(60..3600) }

    context 'one throttle only' do

      let(:rack_attack_throttle_data) do
        { "#{throttle_one}" => { count: request_count, limit: request_limit, period: request_period} }
      end

      it 'should include RateLimit headers' do
        last_response.header.key?('X-RateLimit-Limit').should be true
        last_response.header.key?('X-RateLimit-Remaining').should be true
        last_response.header.key?('X-RateLimit-Reset').should be true
      end

      it 'should return correct rate limit in header' do
        last_response.header['X-RateLimit-Limit'].to_i.should eq request_limit
      end

      it 'should return correct remaining calls in header' do
        last_response.header['X-RateLimit-Remaining'].to_i.should eq(request_limit - request_count)
      end

      it 'should returns the number of seconds remaining in the current throttle period' do
        current_epoch_time = Time.now.to_i
        seconds_until_next_period = request_period - (current_epoch_time % request_period)
        last_response.header['X-RateLimit-Reset'].to_i.should eq(seconds_until_next_period)
      end
    end

    context 'multiple throttles' do

      let(:app) do
        use_throttle = [throttle_one, throttle_two, throttle_three]
        Rack::Builder.new do
          use Rack::Attack::RateLimit, throttle: use_throttle
          run ->(_env) { [200, {}, 'Hello, World!'] }
        end.to_app
      end

      let(:request_limits) { 3.times.map { (1..10_000).to_a.sample } }
      let(:request_counts) { 3.times.map { |index| (1..(request_limits[index] - 10)).to_a.sample } }
      let(:request_periods) { 3.times.map { rand(60..3600) } }

      let(:rack_attack_throttle_data) do
        data = {}
        [throttle_one, throttle_two, throttle_three].each_with_index do |thr, thr_index|
          data["#{thr}"] = { count: request_counts[thr_index], limit: request_limits[thr_index], period: request_periods[thr_index] }
        end
        data
      end

      it 'should include RateLimit headers' do
        last_response.header.key?('X-RateLimit-Limit').should be true
        last_response.header.key?('X-RateLimit-Remaining').should be true
        last_response.header.key?('X-RateLimit-Reset').should be true
      end

      describe 'header values' do
        let(:request_differences) do
          request_limits.map.each_with_index { |limit, index| limit - request_counts[index] }
        end
        let(:min_index) { request_differences.each_with_index.min.last }

        it 'should return correct rate limit' do
          last_response.header['X-RateLimit-Limit'].to_i.should eq request_limits[min_index]
        end

        it 'should return correct remaining calls' do
          last_response.header['X-RateLimit-Remaining'].to_i.should eq(request_differences[min_index])
        end

        it 'should return the correct number of seconds until the current throttled period expires' do
          current_epoch_time = Time.now.to_i
          seconds_until_next_period = request_periods[min_index] - (current_epoch_time % request_periods[min_index])
          last_response.header['X-RateLimit-Reset'].to_i.should eq(seconds_until_next_period)
        end
      end
    end
  end
end
