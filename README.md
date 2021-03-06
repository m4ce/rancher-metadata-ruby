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
api = RancherMetadata::API.new({:api_url => "http://rancher-metadata/2015-12-19"})

puts("Container create index: #{api.get_container_create_index}")
puts("Container service index: #{api.get_container_service_index}")
puts("Container ip: #{api.get_container_ip}")
puts("Container name: #{api.get_container_name}")
puts("Container service name: #{api.get_container_service_name}")
puts("Container hostname: #{api.get_container_hostname}")

api.wait_service_containers do |name, container|
  puts("Container #{name} is up (ip: #{container['primary_ip']}, create index: #{container['create_index']}, service index: #{container['service_index']})")
end

metadata = api.get_service_metadata
puts(metadata.inspect)

puts("Service scale size: #{api.get_service_scale_size}")
```

Look up all containers:
```
api.get_containers.each do |container|
  puts(container.inspect)
end
```

Look up all services:
```
api.get_services.each do |service|
  puts(service.inspect)
end
```

Look up all stacks:
```
api.get_stacks.each do |stack|:
  puts(stack.inspect)
end
```

Look up all hosts:
```
api.get_hosts.each do |host|:
  puts(host.inspect)
end
```

Look up current container:
```
puts(api.get_container.inspect)
```

Look up a container by name:
```
puts(api.get_container("my_container").inspect)
```

Look up a container's IP by name:
```
puts("A container IP #{api.get_container_ip("container_name")}")
```

Look up current service:
```
puts(api.get_service.inspect)
```

Look up a specific service running in the current stack:
```
puts(api.get_service({:service_name => 'my_service'}).inspect)
```

Look up a specific service running in another stack:
```
puts(api.get_service({:service_name => 'my_service', :stack_name => 'my_stack'}).inspect)
```

Look up the current service's containers
```
api.get_service_containers.each do |name, container|
  puts("Container #{name} (ip: #{container['primary_ip']}, create index: #{container['create_index']}, service index: #{container['service_index']})")
end
```

Look up a specific service's containers running in the current stack:
```
api.get_service_containers({:service_name => 'my_service'}).each do |name, container|
  puts("Container #{name} (ip: #{container['primary_ip']}, create index: #{container['create_index']}, service index: #{container['service_index']})")
end
```

Look up a specific service's containers running in an another stack:
```
api.get_service_containers({:service_name => 'my_service', :stack_name => 'my_stack'}).each do |name, container|
  puts("Container #{name} (ip: #{container['primary_ip']}, create index: #{container['create_index']}, service index: #{container['service_index']})")
end
```

Look up current stack:
```
puts(api.get_stack.inspect)
```

Look up a specific stack by name:
```
puts(api.get_stack("my_stack").inspect)
```

Look up services running in current stack:
```
api.get_stack_services.each do |service|
  puts(service.inspect)
end
```

Look up services running in another stack:
```
api.get_stack_services("my_stack").each do |service|
  puts(service.inspect)
end
```

Look up current host:
```
puts(api.get_host.inspect)
```

Look up a specific host by name:
```
puts(api.get_host("my_host").inspect)
```

Returns true if the container is running in Rancher-managed network:
```
if api.is_network_managed?
  puts("I am running in the managed network")
else
  puts("I am running in host-based networking")
end
```

## Contact
Matteo Cerutti - matteo.cerutti@hotmail.co.uk
