$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "../lib")

require 'rspec'
require 'rack/test'
require 'rack/attack/rate-limit'

RSpec::configure do |config|

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.formatter = :documentation
  config.tty = true
end
