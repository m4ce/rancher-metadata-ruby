#
# api.rb
#
# Author: Matteo Cerutti <matteo.cerutti@swisscom.com>
#

require 'net/http'
require 'json'

module RancherMetadata
  class API
    attr_reader :config

    def initialize(config)
      defaults = {
        :api_url => ["http://rancher-metadata/2015-07-25"],
        :max_attempts => 3
      }

      config[:api_url] = [ config[:api_url] ] unless config[:api_url].is_a?(Array) if config.has_key?(:api_url)

      @config = defaults.merge(config)
    end

    def is_error?(data)
      if data.is_a?(Hash) and data.has_key?('code') and data['code'] == 404
        return true
      else
        return false
      end
    end

    def api_get(query)
      success = true
      attempts = 1
      data = nil

      self.config[:max_attempts].times.each do |i|
        self.config[:api_url].each do |api_url|
          begin
            uri = URI.parse("#{api_url}#{query}")
            req = Net::HTTP::Get.new(uri.path, {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
            resp = Net::HTTP.new(uri.host, uri.port).request(req)
            data = JSON.parse(resp.body)
            success = true

            break
          rescue
            raise("Failed to query Rancher Metadata API on #{api_url} - Caught exception (#{$!})")
          end
        end

        i += 1
      end

      raise("Failed to query Rancher Metadata API (#{attempts} out of #{self.config[:max_attempts]} failed)") unless success

      if is_error?(data)
        return nil
      else
        return data
      end
    end

    def get_services()
      api_get("/services")
    end

    def get_service(opts = {})
      if opts.empty?
        return api_get("/self/service")
      else
        raise("Missing rancher service name") unless opts.has_key?(:service_name)

        unless opts.has_key?(:stack_name)
          return api_get("/services/#{opts[:service_name]}")
        else
          self.get_services().each do |service|
            return service if service['stack_name'] == opts[:stack_name] and service['name'] == opts[:service_name]
          end
        end
      end
    end

    def get_containers()
      api_get("/containers")
    end

    def get_container(name = nil)
      if name
        api_get("/containers/#{name}")
      else
        api_get("/self/container")
      end
    end
  end
end
