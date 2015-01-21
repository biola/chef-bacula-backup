name             'bacula-backup'
maintainer       'Biola University'
maintainer_email 'troy.ready@biola.edu'
license          'Apache 2.0'
description      'Installs and autoconfigures bacula backup system'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://github.com/biola/chef-bacula-backup'
issues_url       'https://github.com/biola/chef-bacula-backup/issues'
version          '1.8.0'

%w{ ubuntu debian redhat windows }.each do |os|
  supports os
end

depends        'mysql', '~> 5.5'

%w{ openssl database windows }.each do |dep|
  depends dep
end
