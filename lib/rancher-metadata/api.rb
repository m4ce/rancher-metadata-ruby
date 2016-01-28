#
# api.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

require 'net/http'
require 'json'

module RancherMetadata
  class API
    attr_reader :config

    def initialize(config)
      defaults = {
        :api_url => ["http://rancher-metadata/2015-12-19"],
        :max_attempts => 3
      }

      if config.has_key?(:api_url)
        config[:api_url] = [ config[:api_url] ] unless config[:api_url].is_a?(Array)

        raise("Must pass one or more API endpoints") unless config[:api_url].size > 0
      end

      @config = defaults.merge(config)
    end

    def is_error?(data)
      ( data.is_a?(Hash) and data.has_key?('code') and data['code'] == 404 ) ? true : false
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
            begin
              data = JSON.parse(resp.body)
            rescue JSON::ParserError
              data = resp.body
            end

            success = true

            break
          rescue
            STDERR.puts("Failed to query Rancher Metadata API on #{api_url} - Caught exception (#{$!})")
          end
        end

        i += 1
      end

      raise("Failed to query Rancher Metadata API (#{attempts} out of #{self.config[:max_attempts]} failed)") unless success

      is_error?(data) ? nil : data
    end

    def get_services
      self.api_get("/services")
    end

    def get_service(service = {})
      if service.empty?
        return self.api_get("/self/service")
      else
        raise("Missing rancher service name") unless service.has_key?(:service_name)

        unless service.has_key?(:stack_name)
          return self.api_get("/self/stack/services/#{service[:service_name]}")
        else
          return self.api_get("/stacks/#{service[:stack_name]}/services/#{service[:service_name]}")
        end
      end
    end

    def get_service_field(field, service = {})
      if service.empty?
        return self.api_get("/self/service/#{field}")
      else
        raise("Must provide service name") unless service.has_key?(:service_name)

        unless service.has_key?(:stack_name)
          return self.api_get("/self/stack/services/#{service[:service_name]}/#{field}")
        else
          return self.api_get("/stacks/#{service[:stack_name]}/services/#{service[:service_name]}/#{field}")
        end
      end
    end

    def get_service_scale_size(service = {})
      self.get_service_field("scale", service).to_i
    end

    def get_service_containers(service = {})
      self.get_service_field("containers", service)
    end

    def get_service_metadata(service = {})
      self.get_service_field("metadata", service)
    end

    def get_service_links(service = {})
      self.get_service_field("links", service)
    end

    def wait_service_containers(service = {})
      scale = self.get_service_scale_size(service)

      old = []
      loop do
        containers = self.get_service_containers(service)
        new = containers.keys()

        (new - old).each do |n|
          yield(n, containers[n])
        end

        old = new

        break if new.size >= scale

        sleep(0.5)
      end
    end

    def get_stacks
      self.api_get("/stacks")
    end

    def get_stack(stack_name = nil)
      stack_name ? self.api_get("/stacks/#{stack_name}") : self.api_get("/self/stack")
    end

    def get_stack_services(stack_name = nil)
      stack_name ? self.api_get("/stacks/#{stack_name}/services") : self.api_get("/self/stack/services")
    end

    def get_containers
      self.api_get("/containers")
    end

    def get_container(container_name = nil)
      container = nil

      if container_name
        container = self.api_get("/containers/#{container_name}")
      else
        container = self.api_get("/self/container")
      end

      # FIXME: https://github.com/rancher/cattle/pull/1197
      container['service_suffix'] = self.get_container_service_suffix(container_name) unless container.has_key?('service_suffix')

      container
    end

    def get_container_field(field, container_name = nil)
      container_name ? self.api_get("/containers/#{container_name}/#{field}") : self.api_get("/self/container/#{field}")
    end

    def get_container_id(container_name = nil)
      self.get_container_create_index(container_name)
    end

    def get_container_create_index(container_name = nil)
     i = self.get_container_field("create_index", container_name)
     i ? i.to_i : nil
    end

    def get_container_ip(container_name = nil)
      if container_name
        # FIXME: https://github.com/rancher/rancher/issues/2750
        if self.is_network_managed?
          self.api_get("/self/container/primary_ip")
        else
          self.get_host_ip
        end
      else
        self.api_get("/containers/#{container_name}/primary_ip")
      end
    end

    def get_container_name(container_name = nil)
      self.get_container_field("name", container_name)
    end

    def get_container_service_name(container_name = nil)
      self.get_container_field("service_name", container_name)
    end

    def get_container_stack_name(container_name = nil)
      self.get_container_field("stack_name", container_name)
    end

    def get_container_hostname(container_name = nil)
      self.get_container_field("hostname", container_name)
    end

    def get_container_service_id(container_name = nil)
      self.get_container_service_suffix(container_name)
    end

    def get_container_service_suffix(container_name = nil)
      index = nil

      service_suffix = self.get_container_field("service_suffix", container_name)

      if service_suffix.nil?
        if (i = self.get_container_name(container_name)[/(\d+)$/, 1])
          index = i.to_i
        end
      else
        index = service_suffix.to_i
      end

      index
    end

    def get_container_host_uuid(container_name = nil)
      self.get_container_field("host_uuid", container_name)
    end

    def is_network_managed?
      self.get_container_id ? true : false
    end

    def get_host(host_name = nil)
      host_name ? self.api_get("/hosts/#{host_name}") : self.api_get("/self/host")
    end

    def get_host_field(field, host_name = nil)
      host_name ? self.api_get("/hosts/#{host_name}/#{field}") : self.api_get("/self/host/#{field}")
    end

    def get_host_ip(host_name = nil)
      self.get_host_field("agent_ip", host_name)
    end

    def get_host_uuid(host_name = nil)
      self.get_host_field("uuid", host_name)
    end

    def get_host_name(host_name = nil)
      self.get_host_field("name", host_name)
    end
  end
end
