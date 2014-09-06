#
# Cookbook Name:: bacula-backup
# Recipe:: client
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

package "bacula-client"
service "bacula-fd" do
  supports :restart => true
end

node.set_unless['bacula']['fd']['password'] = secure_password
node.set_unless['bacula']['fd']['password_monitor'] = secure_password

template "/etc/bacula/bacula-fd.conf" do
  group node['bacula']['group']
  mode 0640
  notifies :restart, "service[bacula-fd]"
end

# include scripts for mysql backup
if node['mysql'] && node['mysql']['server_root_password']

  template '/usr/local/sbin/backupdbs' do
    mode 0500
    user node['bacula']['user']
    group 'root'
  end

  directory '/var/local/mysqlbackups' do
    user node['bacula']['user']
    action :create
    recursive true
  end

  template '/usr/local/sbin/restoredbs' do
    mode 0500
    user node['bacula']['user']
    group 'root'
  end
  directory '/var/local/mysqlrestores' do
    user node['bacula']['user']
    action :create
    recursive true
  end

end

# include scripts for ldap backup
if node['openldap'] && node['openldap']['slapd_type'] == "master"
  template '/usr/local/sbin/backupldap' do
    mode 0500
    user node['bacula']['user']
    group 'root'
  end

  directory '/var/local/ldapbackups' do
    user node['bacula']['user']
    action :create
    recursive true
  end

  template '/usr/local/sbin/restoreldap' do
    mode 0500
    user node['bacula']['user']
    group 'root'
  end
  directory '/var/local/ldaprestores' do
    user node['bacula']['user']
    action :create
    recursive true
  end

end

# include scritps for chef server backup
if node['fqdn'] == "chef.#{node['domain']}"

  package "python-couchdb"
  package "python-pkg-resources"

  node.set['bacula']['fd']['files'] = {
    'includes' => ["/var/lib/chef", "/etc/chef" "/etc/couchdb"]
  }

  remote_file "/usr/local/sbin/chef_server_backup.rb" do
    source "https://raw.github.com/jtimberman/knife-scripts/master/chef_server_backup.rb"
  end

  template '/usr/local/sbin/backupchef' do
    mode 0500
    user node['bacula']['user']
    group 'root'
  end

  directory "/var/local/chefbackups" do
    user node['bacula']['user']
    action :create
    recursive true
  end

  template '/usr/local/sbin/restorechef' do
    mode 0500
    user node['bacula']['user']
    group 'root'
  end

  directory '/var/local/chefrestores' do
    user node['bacula']['user']
    action :create
    recursive true
  end

end
