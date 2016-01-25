lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rancher-metadata/version'
require 'date'

Gem::Specification.new do |s|
  s.name = 'rancher-metadata'
  s.authors = ['Matteo Cerutti']
  s.date = Date.today.to_s
  s.description = 'Ruby library for Rancher Metadata API'
  s.email = '<matteo.cerutti@hotmail.co.uk>'
  s.files = Dir.glob('{lib}/**/*') + %w(LICENSE README.md)
  s.require_paths = ["lib"]
  s.homepage = 'https://github.com/m4ce/ruby-rancher_metadata'
  s.license = 'Apache 2.0'
  s.summary = 'Ruby library that allows to interact with the Rancher Metadata REST API'
  s.version = RancherMetadata.version

  s.add_runtime_dependency 'json', '~> 0'
end
