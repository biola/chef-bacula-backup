#
# Cookbook Name:: bacula-backup
# Recipe:: server
#
# Copyright 2012, 2013 computerlyrik
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

node.set['bacula']['fd']['address'] = "127.0.0.1"
include_recipe 'bacula-backup::client'

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

################### MYSQL SERVER SETUP
include_recipe "mysql::server"
include_recipe "database::mysql"
mysql_connection_info = { :host => "localhost", :username => 'root', :password => node['mysql']['server_root_password'] }

node.set_unless['bacula']['mysql_password'] = secure_password

mysql_database_user node['bacula']['mysql_user'] do
  password  node['bacula']['mysql_password']
  database_name node['bacula']['mysql_user']
  connection mysql_connection_info
#  notifies :run, resources(:execute=>"create_mysql_tables")
  action [:create, :grant]
end

mysql_database node['bacula']['mysql_user'] do
  connection mysql_connection_info
  action :create
end

cookbook_file "/etc/bacula/mysql_tables" do
  if platform?("ubuntu") # precise 12.04
    source "mysql_tables_14"
  else # debian 6
    source "mysql_tables_12"
  end
end

mysql_database "bacula" do
  connection mysql_connection_info
  sql { ::File.open("/etc/bacula/mysql_tables").read }
  action :nothing
  subscribes :query, "mysql_database[#{node['bacula']['mysql_user']}]"
end

################### Install and configure bacula

package "bacula-director-mysql"
service "bacula-director"

node.set_unless['bacula']['dir']['password'] = secure_password
node.set_unless['bacula']['dir']['password_monitor'] = secure_password

if Chef::Config[:solo]
  bacula_clients = []
  bacula_storage = node
else
  bacula_clients = search(:node, 'recipes:bacula-backup\:\:client')
  bacula_storage = search(:node, 'recipes:bacula-backup\:\:storage').first
end

template "/etc/bacula/bacula-dir.conf" do
  group node['bacula']['group']
  mode 0640
  notifies :restart, "service[bacula-director]"
  variables(
      :bacula_clients => bacula_clients,
      :bacula_storage => bacula_storage
    )
end

template "/etc/bacula/common_default_passwords" do
  group node['bacula']['group']
  mode 0640
end
