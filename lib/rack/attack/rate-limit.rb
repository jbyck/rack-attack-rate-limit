require "rack/attack/rate-limit/version"

module Rack
  module Attack
    class RateLimit
    
      attr_reader :app, :options
      
      RACK_ATTACK_KEY = 'rack.attack.throttle_data'
    
      def initialize(app, options = {})
        @app = app
        @options = default_options.merge(options)
      end
  
      def call(env)
        # If env does not have necessary data to extract rate limit data for the provider, then app.call
        return app.call(env) unless rate_limit_available?     
        # Otherwise, add rate limit headers
        status, headers, body = app.call(env)
        add_rate_limit_headers!(headers, env)
        [status, headers, body]  
      end
      
      # Returns env key used by Rack::Attack to namespace data
      #
      # Returns string
      def rack_attack_key
        RACK_ATTACK_KEY
      end
    
      # Default options to configure Rack::RateLimit
      #
      # Returns hash
      def default_options
        { namespace: 'throttle' }
      end
      
      # Return hash of headers with Rate Limiting data
      #
      # headers - Hash of headers
      #
      # Returns hash
      def add_rate_limit_headers!(headers, env)
        headers['X-RateLimit-Limit']      = rate_limit_limit(env).to_s
        headers['X-RateLimit-Remaining']  = rate_limit_remaining(env).to_s
        headers
      end
    
      protected
    
      # RateLimit upper limit from Rack::Attack
      #
      # env - Hash
      #
      # Returns Fixnum
      def rate_limit_limit(env)
        env[rack_attack_key][options[:namespace]][:limit]
      end
    
      # RateLimit remaining request from Rack::Attack
      #
      # env - Hash
      #
      # Returns Fixnum
      def rate_limit_remaining(env)
        limit_from_rack_attack(env) - env[rack_attack_key][options[:namespace]][:count]
      end
        
      # Rate Limit available method for Rack::Attack provider
      # Checks the key identifed by options[:namespace] under the rack.attak.throttle_data env hash key
      #
      # env - Hash
      #
      # Returns boolean 
      def rate_limit_available?(env)
        env.key?(rack_attack_key) and env[rack_attack_key].key?(options[:namespace])
      end
    
    end
  end
end
