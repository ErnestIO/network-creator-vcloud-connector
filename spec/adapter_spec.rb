# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require_relative 'spec_helper'

describe 'vcloud_network_creator_microservice' do
  let!(:provider) { double('provider', foo: 'bar') }

  before do
    allow_any_instance_of(Object).to receive(:sleep)
    require_relative '../adapter'
  end

  describe '#create_network' do
    let!(:data)   do
      { router_name: 'adria-vse',
        router_type: 'vcloud',
        datacenter_username: 'acidre@r3labs-development',
        datacenter_name: 'r3-acidre',
        datacenter_password: 'ed7d0a9ffed74b2d3bc88198cbe7948c',
        client_name: 'r3labs-development',
        name: 'cdg-145-salt',
        start_address: '10.64.4.5',
        end_address: '10.64.4.250',
        netmask: '255.255.255.0',
        gateway: '10.64.4.1'

      }
    end
    let!(:datacenter)   { double('datacenter', router: true, add_private_network: true) }

    before do
      allow_any_instance_of(Provider).to receive(:initialize).and_return(true)
      allow_any_instance_of(Provider).to receive(:datacenter).and_return(datacenter)
      allow_any_instance_of(PrivateNetwork).to receive(:initialize).and_return(true)
      allow_any_instance_of(PrivateNetwork).to receive(:instantiate).and_return(true)
    end

    it 'create a network on vcloud' do
      expect(create_network(data)).to eq 'network.create.vcloud.done'
    end
  end
end
