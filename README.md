# Ruby library for Rancher Metadata API
This is a simple Ruby library that allows to interact with the Rancher Metadata REST API.

Pull requests to add additional API features (as documented at http://docs.rancher.com/rancher/metadata-service/) are very welcome. I only implemented what I needed.

## Install
To install it simply issue the following command:

```
gem install rancher-metadata
```

## Usage
```
require 'rancher-metadata'
api = RancherMetadata::API.new({:api_url => "http://rancher-metadata/2015-07-25"})

puts("Container ID: #{api.get_container_id}")
puts("Container Service ID: #{api.get_container_service_id}")
puts("Container IP: #{api.get_container_ip}")
puts("Container Name: #{api.get_container_name}")
puts("Container Service Name: #{api.get_container_service_name}")
puts("Container Hostname: #{api.get_container_hostname}")

api.wait_service_containers() do |container|
  puts("Container #{container} is up (IP: #{api.get_container_ip(container)}, Index: #{api.get_container_id})")
end

metadata = api.get_service_metadata()
puts(metadata.inspect)
```

## Contact
Matteo Cerutti - matteo.cerutti@hotmail.co.uk
