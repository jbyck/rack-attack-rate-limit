# Rack::Attack::RateLimit

Include RateLimit headers from Rack::Attack throttles.

## Installation

Install or add to your gem file, the [rack-attack](http://rubygems.org/gems/rack-attack) gem and the [rack-attack-rate-limit](javascript:;) gem. 

Gemfile:

```ruby
gem install 'rack-attack'
gem install 'rack-attack-rate-limit'
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

* 'X-RateLimit-Limit' - The total number of requests allowed.
* 'X-RateLimit-Remaining' - The number of remaining requests. 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
