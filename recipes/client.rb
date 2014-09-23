#
# Cookbook Name:: bacula-backup
# Recipe:: client
#
# Copyright 2012, computerlyrik
# Copyright 2014, Biola University
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

case node['platform_family']
when 'rhel'
  remote_file "#{Chef::Config[:file_cache_path]}/#{node['bacula']['fd']['packages']['lzo_url'].split('/').last}" do
    source node['bacula']['fd']['packages']['lzo_url']
    checksum node['bacula']['fd']['packages']['lzo_checksum']
  end
  rpm_package "lzo-2.06" do
    source "#{Chef::Config[:file_cache_path]}/#{node['bacula']['fd']['packages']['lzo_url'].split('/').last}"
  end
  
  remote_file "#{Chef::Config[:file_cache_path]}/#{node['bacula']['fd']['packages']['libfastlz_url'].split('/').last}" do
    source node['bacula']['fd']['packages']['libfastlz_url']
    checksum node['bacula']['fd']['packages']['libfastlz_checksum']
  end
  rpm_package "libfastlz-0.1" do
    source "#{Chef::Config[:file_cache_path]}/#{node['bacula']['fd']['packages']['libfastlz_url'].split('/').last}"
  end
  
  remote_file "#{Chef::Config[:file_cache_path]}/#{node['bacula']['fd']['packages']['bareoscommon_url'].split('/').last}" do
    source node['bacula']['fd']['packages']['bareoscommon_url']
    checksum node['bacula']['fd']['packages']['bareoscommon_checksum']
  end
  rpm_package "bareos-common" do
    source "#{Chef::Config[:file_cache_path]}/#{node['bacula']['fd']['packages']['bareoscommon_url'].split('/').last}"
  end
  
  remote_file "#{Chef::Config[:file_cache_path]}/#{node['bacula']['fd']['packages']['bareosfd_url'].split('/').last}" do
    source node['bacula']['fd']['packages']['bareosfd_url']
    checksum node['bacula']['fd']['packages']['bareosfd_checksum']
  end
  rpm_package "bareos-filedaemon" do
    source "#{Chef::Config[:file_cache_path]}/#{node['bacula']['fd']['packages']['bareosfd_url'].split('/').last}"
  end
  
  clientservice = 'bareos-fd'
  templatefile = '/etc/bareos/bareos-fd.conf'
when 'windows'
  clientservice = 'Bacula-fd'
  templatefile = 'c:/program files/bacula/bacula-fd.conf'
  # Using the windows cookbook lwrp to install the fd, as they are distributed as EXEs
  include_recipe 'windows::default'
  windows_package node['bacula']['fd']['packages']['win_displayname'] do
    if node['kernel']['machine'] == "x86_64"
      source node['bacula']['fd']['packages']['win_url']
      checksum node['bacula']['fd']['packages']['win_checksum']
    else
      source node['bacula']['fd']['packages']['win_url_32bit']
      checksum node['bacula']['fd']['packages']['win_checksum_32bit']
    end
    action :install
    options "/S"
    installer_type :custom
  end
else
  package "bacula-client"
  
  clientservice = 'bacula-fd'
  templatefile = '/etc/bacula/bacula-fd.conf'
end

service clientservice do
  supports :status => true, :start => true, :stop => true, :restart => true
  action :start
end

node.set_unless['bacula']['fd']['password'] = secure_password
node.set_unless['bacula']['fd']['password_monitor'] = secure_password

template templatefile do
  group node['bacula']['group'] unless node['platform_family'] == 'windows'
  mode 0640
  source 'bacula-fd.conf.erb'
  notifies :restart, "service[#{clientservice}]"
end

# FIXME - commenting these out for now so they aren't deployed everywhere
# include scripts for mysql backup
#if node['mysql'] && node['mysql']['server_root_password']
#
#  template '/usr/local/sbin/backupdbs' do
#    mode 0500
#    user node['bacula']['user']
#    group 'root'
#  end
#
#  directory '/var/local/mysqlbackups' do
#    user node['bacula']['user']
#    action :create
#    recursive true
#  end
#
#  template '/usr/local/sbin/restoredbs' do
#    mode 0500
#    user node['bacula']['user']
#    group 'root'
#  end
#  directory '/var/local/mysqlrestores' do
#    user node['bacula']['user']
#    action :create
#    recursive true
#  end
#
#end

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
