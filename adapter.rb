# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require 'rubygems'
require 'bundler/setup'
require 'json'

require 'myst'

include Myst::Providers::VCloud

def dns(data)
  return ['8.8.8.8', '8.8.4.4'] if data[:dns].nil?
  data[:dns]
end

def create_network(data)
  values = data.values_at(:datacenter_name, :router_name, :name).compact
  return false unless data[:router_type] == 'vcloud' && values.length == 3

  credentials = data[:datacenter_username].split('@')
  provider = Provider.new(endpoint:     data[:vcloud_url],
                          organisation: credentials.last,
                          username:     credentials.first,
                          password:     data[:datacenter_password])
  datacenter      = provider.datacenter(data[:datacenter_name])
  router          = datacenter.router(data[:router_name])

  private_network_request = PrivateNetwork.new.instantiate(router,
                                                           data[:name],
                                                           { start_address: data[:start_address],
                                                             end_address:   data[:end_address] },
                                                           data[:netmask],
                                                           data[:gateway],
                                                           dns(data))
  datacenter.add_private_network(private_network_request)
  'network.create.vcloud.done'
rescue => e
  puts e
  puts e.backtrace
  'network.create.vcloud.error'
end

unless defined? @@test
  @data       = { id: SecureRandom.uuid, type: ARGV[0] }
  @data.merge! JSON.parse(ARGV[1], symbolize_names: true)
  original_stdout = $stdout
  $stdout = StringIO.new
  begin
    @data[:type] = create_network(@data)
    if @data[:type].include? 'error'
      @data['error'] = { code: 0, message: $stdout.string.to_s }
    end
  ensure
    $stdout = original_stdout
  end

  puts @data.to_json
end
