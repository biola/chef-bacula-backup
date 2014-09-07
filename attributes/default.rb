unless node['platform_family'] == 'rhel'
  default['bacula']['user'] = "bacula"
  default['bacula']['group'] = "bacula"
else
  default['bacula']['user'] = "bareos"
  default['bacula']['group'] = "bareos"
end

default['bacula']['messages']['mail'] = "bacula@#{node['domain']}"
default['bacula']['messages']['operator'] = node['bacula']['messages']['mail']
