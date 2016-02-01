name             'bacula-backup'
maintainer       'Biola University'
maintainer_email 'troy.ready@biola.edu'
license          'Apache 2.0'
description      'Installs and autoconfigures bacula backup system'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://github.com/biola/chef-bacula-backup'
issues_url       'https://github.com/biola/chef-bacula-backup/issues'
version          '1.10.1'

%w{ ubuntu debian redhat windows mac_os_x }.each do |os|
  supports os
end

depends          'database', '< 4.0'
depends          'homebrew', '~> 1.13'
depends          'mysql', '~> 5.5'
depends          'mysql-chef_gem', '~> 0.0.2'

%w{ openssl windows }.each do |dep|
  depends dep
end
