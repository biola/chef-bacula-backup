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
  
  # If a previous version of this cookbook installed v13.2, we won't be
  # able to install the last packages individually. Check for the old
  # version and remove it first.
  current_pkg = Mixlib::ShellOut.new('yum list bareos-filedaemon')
  current_pkg.run_command
  if current_pkg.stdout.include?('13.2.2-7.1.el5') and !node['bacula']['fd']['packages']['bareosfd_url'].include?('13.2.2-7.1.el5')
    execute 'yum -y erase bareos-filedaemon bareos-common'
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
  config_dir = '/etc/bacula'
  templatefile = '/etc/bareos/bareos-fd.conf'
  pki_keypair_location = '/etc/bacula/bacula-fd.pem'
  pki_masterkey_location = '/etc/bacula/masterkey.pem'
when 'windows'
  clientservice = 'Bacula-fd'
  config_dir = 'c:/program files/bacula'
  templatefile = 'c:/program files/bacula/bacula-fd.conf'
  pki_keypair_location = '"C:\\\\Program Files\\\\Bacula\\\\bacula-fd.pem"'
  pki_masterkey_location = '"C:\\\\Program Files\\\\Bacula\\\\masterkey.pem"'
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
when 'mac_os_x'
  include_recipe 'homebrew::default'

  # roll back formula to 5.2 to match current debian bacula version
  # v7 client will not work properly with v5 dir/sd
  remote_file '/usr/local/Library/Formula/bacula-fd.rb' do
    source 'https://raw.githubusercontent.com/Homebrew/homebrew/'\
           '401cbaa9949086f5d6269e0fd4ce637cc9ac19df/Library/Formula/'\
           'bacula-fd.rb'
    checksum '67882d7509793760054c4f81f18e8f1a90a9477e85ef6b9cfbc4c78218f2365b'
    owner node['homebrew']['owner']
    mode 0644
  end
  package 'bacula-fd'

  clientservice = 'bacula-fd'
  config_dir = '/usr/local/etc'
  templatefile = '/usr/local/etc/bacula-fd.conf'
  pki_keypair_location = '/usr/local/etc/bacula-fd.pem'
  pki_masterkey_location = '/usr/local/etc/masterkey.pem'
else
  package "bacula-client"
  
  clientservice = 'bacula-fd'
  config_dir = '/etc/bacula'
  templatefile = '/etc/bacula/bacula-fd.conf'
  pki_keypair_location = '/etc/bacula/bacula-fd.pem'
  pki_masterkey_location = '/etc/bacula/masterkey.pem'
end

service clientservice do
  supports :status => true, :start => true, :stop => true, :restart => true
  action :start
  not_if { node['platform_family'] == 'mac_os_x' }
end

node.set_unless['bacula']['fd']['password'] = secure_password
node.set_unless['bacula']['fd']['password_monitor'] = secure_password

# Encryption support
if node['bacula']['fd']['encrypt_backups']
  unless File.exist?("#{config_dir}/bacula-fd.pem")
    require 'openssl'
    key = OpenSSL::PKey::RSA.new(2048)
    public_key = key.public_key
    subject = node['bacula']['fd']['pki_subject']
    subject += "/CN=#{node['fqdn']}" unless subject.include?('/CN=')
    cert = OpenSSL::X509::Certificate.new
    cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
    cert.not_before = Time.now
    cert.not_after = Time.now + 365 * 24 * 60 * 60
    cert.public_key = public_key
    cert.serial = 0x0
    cert.version = 2
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = cert
    cert.extensions = [
      ef.create_extension("basicConstraints", "CA:TRUE", true),
      ef.create_extension("subjectKeyIdentifier", "hash"),
      ef.create_extension("keyUsage", "cRLSign,keyCertSign", true)
    ]
    cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                           "keyid:always,issuer:always")

    cert.sign key, OpenSSL::Digest::SHA256.new

    keypair = "#{key}#{cert.to_pem}"

    file "#{config_dir}/bacula-fd.pem" do
      content keypair
      unless node['platform_family'] == 'windows'
        group node['bacula']['group']
        mode 0640
      end
      action :create_if_missing
      sensitive true
    end
  end

  # Deploy the master key (public key only) from attribute if defined
  if !File.exist?("#{config_dir}/masterkey.pem") &&
     node['bacula']['fd']['pki_masterkey_public']
    masterkey_public = node['bacula']['fd']['pki_masterkey_public']
    masterkey_public << "\n" unless masterkey_public.end_with?("\n")
    file "#{config_dir}/masterkey.pem" do
      content masterkey_public
      unless node['platform_family'] == 'windows'
        group node['bacula']['group']
        mode 0640
      end
      action :create_if_missing
    end
  elsif !File.exist?("#{config_dir}/masterkey.pem")
    # Override the location here so it isn't defined in the configuration file
    pki_masterkey_location = false
  end

end

template templatefile do
  unless node['platform_family'] == 'windows'
    group node['bacula']['group']
    mode 0640
  end
  source 'bacula-fd.conf.erb'
  unless node['platform_family'] == 'mac_os_x'
    notifies :restart, "service[#{clientservice}]"
  end
  if node['bacula']['fd']['encrypt_backups']
    variables(
     pki_keypair_location: pki_keypair_location,
     pki_masterkey_location: pki_masterkey_location
    )
  end
end

# FIXME: setup as an OS X service
execute 'start_osx_baculafd' do
  only_if { node['platform_family'] == 'mac_os_x' }
  not_if 'ps aux | grep -i bacula-f[d]'
  command 'bacula-fd -c /usr/local/etc/bacula-fd.conf'
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
