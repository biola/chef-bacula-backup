case node['platform_family']
when 'rhel'
  default['bacula']['user'] = 'bareos'
  default['bacula']['group'] = 'bareos'
when 'mac_os_x'
  default['bacula']['user'] = nil
  default['bacula']['group'] = 'wheel'
else
  default['bacula']['user'] = 'bacula'
  default['bacula']['group'] = 'bacula'
end

default['bacula']['messages']['mail'] = "bacula@#{node['domain']}"
default['bacula']['messages']['operator'] = node['bacula']['messages']['mail']
default['bacula']['messages']['mail_server'] = "localhost"
default['bacula']['messages']['mail_to_send'] = "all, !skipped"
