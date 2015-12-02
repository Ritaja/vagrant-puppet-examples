node 'vagrant-ubuntu-trusty-64' {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  include nodes
}
#include virtual_groups
#include virtual_users