default['bacula']['mysql_user'] = "bacula"

default['bacula']['dir']['address'] = node['ipaddress']

default['bacula']['volume_size'] = "1G"
default['bacula']['volume_max'] = 50
default['bacula']['label_format'] = "BaculaFile"

default['bacula']['dir']['max_concurrent_jobs'] = "1"
