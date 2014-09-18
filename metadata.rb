name             "bacula-backup"
maintainer       "Biola University"
maintainer_email "troy.ready@biola.edu"
license          "Apache 2.0"
description      "Installs and autoconfigures bacula backup system"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.3.0"

%w{ ubuntu debian redhat }.each do |os|
  supports os
end

depends        "mysql", "~> 5.5"

%w{ openssl database }.each do |dep|
  depends dep
end
