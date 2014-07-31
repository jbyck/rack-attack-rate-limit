# Rack::Attack::RateLimit

[![Build Status](https://travis-ci.org/jbyck/rack-attack-rate-limit.png?branch=master)](https://travis-ci.org/jbyck/rack-attack-rate-limit)

Add rate limit headers for [Rack::Attack](https://github.com/kickstarter/rack-attack) throttles.

## Installation

Install the gem:

```shell
gem install 'rack-attack-rate-limit'
```

In your gemfile:
```ruby
gem 'rack-attack-rate-limit', require: 'rack/attack/rate-limit'
```



And then execute:
```shell
bundle
```

## Usage

Rack::Attack::RateLimit expects a Rack::Attack throttle to be defined:

```ruby
Rack::Attack.throttle('my_throttle') do |req|
  req.ip
end
```

To include rate limit headers for this throttle, include the Rack::Attack::RateLimit middleware

For Rails 3+:

```ruby
config.middleware.use Rack::Attack::RateLimit, throttle: 'my_throttle'
```

Currently, Rack::Attack::RateLimit can only be configured to return rate limit headers for a single throttle, whose name can be specified as an option.

Rate limit headers are:

* 'X-Rate-Limit-Limit' - The total number of requests allowed.
* 'X-Rate-Limit-Remaining' - The number of remaining requests.
* 'X-Rate-Limit-Period' - The time period, in seconds, that the X-Rate-Limit-Limit applies to. 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
