#
# Cookbook Name:: bacula-backup
# Recipe:: storage
#
# Copyright 2012, computerlyrik
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

node.set_unless['bacula']['sd']['password'] = secure_password
node.set_unless['bacula']['sd']['password_monitor'] = secure_password
# node.save

package "bacula-sd"
service "bacula-sd"

directory node['bacula']['sd']['backup_dir'] do
  user node['bacula']['group']
  group node['bacula']['group']
  recursive true
  action :create
end

remote_mount = node['bacula']['sd']['remote_connection'] && node['bacula']['sd']['remote_password']

if remote_mount
  package "sshfs"

  template "/etc/bacula/scripts/storage_remote_mount" do
    mode 0500
    user node['bacula']['user']
    group 'root'
  end
end

template "/etc/bacula/bacula-sd.conf" do
  group node['bacula']['group']
  mode 0640
  variables(:remote_mount => remote_mount)
  notifies :restart, "service[bacula-sd]"
end
