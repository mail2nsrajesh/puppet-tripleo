# Copyright 2016 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: tripleo::profile::base::neutron::ovs
#
# Neutron OVS Agent profile for tripleo
#
# === Parameters
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
# [*vhostuser_socket_dir*]
#   (Optional) vhostuser socket dir, The directory where $vhostuser_socket_dir
#   will be created with correct permissions, inorder to support vhostuser
#   client mode.

class tripleo::profile::base::neutron::ovs(
  $step                 = Integer(hiera('step')),
  $vhostuser_socket_dir = hiera('neutron::agents::ml2::ovs::vhostuser_socket_dir', undef)
) {
  include ::tripleo::profile::base::neutron

  if $step >= 5 {
    if $vhostuser_socket_dir {
      file { $vhostuser_socket_dir:
        ensure => directory,
        owner  => 'qemu',
        group  => 'qemu',
        mode   => '0775',
      }
    }

    include ::neutron::agents::ml2::ovs

    # Optional since manage_service may be false and neutron server may not be colocated.
    Service<| title == 'neutron-server' |> -> Service<| title == 'neutron-ovs-agent-service' |>
  }

}
