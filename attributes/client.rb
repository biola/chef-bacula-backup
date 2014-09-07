default['bacula']['fd']['address'] = node['ipaddress']

# RHEL 5 clients will use these pre-compiled bareos packages
if node['platform_family'] == 'rhel'
  default['bacula']['fd_packages']['lzo_url'] = 'http://download.bareos.org/bareos/release/latest/RHEL_5/x86_64/lzo-2.06-1.1.x86_64.rpm'
  default['bacula']['fd_packages']['lzo_checksum'] = '3bfd74fb282b8506fa6306c06d93eb506ebefca24c2b697d5e65439b04cca9cf'
  default['bacula']['fd_packages']['libfastlz_url'] = 'http://download.bareos.org/bareos/release/latest/RHEL_5/x86_64/libfastlz-0.1-2.1.x86_64.rpm'
  default['bacula']['fd_packages']['libfastlz_checksum'] = 'd861cb937ca50e02768b348c1174648bacea973969d6c41e721332a4cc6cfbcf'
  default['bacula']['fd_packages']['bareoscommon_url'] = 'http://download.bareos.org/bareos/release/latest/RHEL_5/x86_64/bareos-common-13.2.2-7.1.el5.x86_64.rpm'
  default['bacula']['fd_packages']['bareoscommon_checksum'] = '331b66468609d4b502d302dc579b31bf30d3948b78c0cba86d37bc599dbd3c31'
  default['bacula']['fd_packages']['bareosfd_url'] = 'http://download.bareos.org/bareos/release/latest/RHEL_5/x86_64/bareos-filedaemon-13.2.2-7.1.el5.x86_64.rpm'
  default['bacula']['fd_packages']['bareosfd_checksum'] = '0bb5347ca7670d5a5a75462b539f9419fc16e5e5ed13ab90b305538a8fca5cc8'
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
