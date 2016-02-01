default['bacula']['fd']['address'] = node['ipaddress']
default['bacula']['fd']['client_name'] = node['fqdn']
default['bacula']['fd']['encrypt_backups'] = false
default['bacula']['fd']['pki_masterkey_public'] = false
default['bacula']['fd']['pki_subject'] = '/C=US/ST=California/L=San Francisco/O=BaculaClient/OU=BaculaOperators'
default['bacula']['fd']['file_retention'] = '30 days'
default['bacula']['fd']['job_retention'] = '6 months'

case node['platform_family']
when 'rhel'
  # RHEL 5 clients will use these pre-compiled bareos packages
  default['bacula']['fd']['packages']['lzo_url'] = 'http://download.bareos.org/bareos/release/latest/RHEL_5/x86_64/lzo-2.06-1.2.el5.x86_64.rpm'
  default['bacula']['fd']['packages']['lzo_checksum'] = '269178d23066a0488182eedccfbaa88461d5a59519464234e84de6ddac910a02'
  default['bacula']['fd']['packages']['libfastlz_url'] = 'http://download.bareos.org/bareos/release/latest/RHEL_5/x86_64/libfastlz-0.1-6.2.el5.x86_64.rpm'
  default['bacula']['fd']['packages']['libfastlz_checksum'] = 'b889b631f814d375eb9a631be6f9e9fa1fa91b6cda0ca82e01e62b189964eb19'
  default['bacula']['fd']['packages']['bareoscommon_url'] = 'http://download.bareos.org/bareos/release/latest/RHEL_5/x86_64/bareos-common-14.2.2-46.1.el5.x86_64.rpm'
  default['bacula']['fd']['packages']['bareoscommon_checksum'] = '086592c47ae6b3d8b00c627c79dd5e1af3684f28349ecb016ecce07f6e20076f'
  default['bacula']['fd']['packages']['bareosfd_url'] = 'http://download.bareos.org/bareos/release/latest/RHEL_5/x86_64/bareos-filedaemon-14.2.2-46.1.el5.x86_64.rpm'
  default['bacula']['fd']['packages']['bareosfd_checksum'] = '69a964d8bbf2aa53bd86905f2155e8c9ee30b4bd9725e8bbf6242373f5ca5476'

  default['bacula']['fd']['working_directory'] = '/var/lib/bareos'
  default['bacula']['fd']['pid_directory'] = '/var/lib/bareos'
  default['bacula']['fd']['max_con_jobs'] = '20'

when 'windows'
  default['bacula']['fd']['packages']['win_displayname'] = "Bacula"
  default['bacula']['fd']['packages']['win_url'] = "http://sourceforge.net/projects/bacula/files/Win32_64/5.2.10/bacula-win64-5.2.10.exe/download"
  default['bacula']['fd']['packages']['win_checksum'] = "c29af565845a323871caf8aaa90ad38d10d8e0b8bab1903f8cdbce801659fe8a"
  default['bacula']['fd']['packages']['win_url_32bit'] = "http://sourceforge.net/projects/bacula/files/Win32_64/5.2.10/bacula-win32-5.2.10.exe/download"
  default['bacula']['fd']['packages']['win_checksum_32bit'] = "09d6dcc6287ac3f5ba3af4f67cbe9611124e1f49de7786c1eaa02ca069a6e182"

  default['bacula']['fd']['working_directory'] = 'C:\\\\Program Files\\\\Bacula\\\\working'
  default['bacula']['fd']['pid_directory'] = 'C:\\\\Program Files\\\\Bacula\\\\working'
  default['bacula']['fd']['max_con_jobs'] = '10'

when 'debian'
  default['bacula']['fd']['working_directory'] = '/var/lib/bacula'
  default['bacula']['fd']['pid_directory'] = '/var/run/bacula'
  default['bacula']['fd']['max_con_jobs'] = '20'

when 'mac_os_x'
  default['bacula']['fd']['working_directory'] = '/usr/local/var/lib/bacula'
  default['bacula']['fd']['pid_directory'] = '/usr/local/var/run'
  default['bacula']['fd']['max_con_jobs'] = '20'
end



## AUTODETECT BACKUPABLE DATA

# ZARAFA
if node['zarafa']
  node.set['bacula']['fd']['files'] = {
    'includes' => [
      '/var/lib/zarafa',
      '/usr/share/zarafa',
      '/usr/share/httpd.conf',
      '/etc/postfix',
      '/etc/default/saslauthd',
      '/etc/zarafa',
      '/etc/apache2/httpd.conf'
    ]
  }
end

# GITHUB BACKUP
if node['github-backup']
  node.set['bacula']['fd']['files'] = {
    'includes' => [node['github-backup']['backup_dir']]
  }
end

# GITLAB
if node['gitlab']
  node.set['bacula']['fd']['files'] = {
    'includes' => [
      node['gitlab']['home'],
      '/var/lib/redis'
    ]
  }
end

# SPARKLESHARE
if node['sparkleshare'] && node['sparkleshare']['dashboard']
  node.set['bacula']['fd']['files'] = {
    'includes' => [
      node['sparkleshare']['dashboard']['dir']
    ]
  }
end

# FIREFOX
unless node['ff_sync'].nil?
  node.set['bacula']['fd']['files'] = {
    'includes' => [
      node['ff_sync']['server_dir']
    ]
  }
end

#--------------------Collectd----------------#
# COLLECTD::DEFAULT
if node['collectd']
  node.set['bacula']['fd']['files'] = {
    'includes' => [
      default['collectd']['base_dir'],
      default['collectd']['plugin_dir'],
      default['collectd']['types_db']
    ]
  }
# COLLECTD::WEB
  if node['collectd']['collectd_web']
    node.set['bacula']['fd']['files'] = {
      'includes' => [
        default['collectd']['collectd_web']['path']
      ]
    }
  end
end

# CHEF-SERVER

# if is chef server #TODO
#   node.set['bacula']['fd']['files'] = {
#     'includes' => ['/var/lib/chef', '/etc/chef/etc/couchdb']
#   }
# end
