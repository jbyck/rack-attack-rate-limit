# rack-attack-rate-limit changelog

## Unreleased

* Set the 'X-RateLimit-Reset' header to the timestamp when the current throttle period expires.

## 1.1.0

* Add support for multiple throttles.

## 1.0.0

* Support for Rails 4
* Rack::Attack should be *class* not a *module*.
* Define Rack::Attack class if not already defined.
* Style changes.

## 0.1.0

* Initial release.
