# --- Apt-get update ---------------------------------------------------------

exec { 'apt-update':
  command => "/usr/bin/apt-get update",
  onlyif => "/bin/bash -c 'exit $(( $(( $(date +%s) - $(stat -c %Y /var/lib/apt/lists/$( ls /var/lib/apt/lists/ -tr1|tail -1 )) )) <= 604800 ))'"
}

Exec["apt-update"] -> Package <| |>

package { "libpq-dev": ensure => present }

class { 'rbenv':
  install_dir => '/opt/rbenv',
  latest      => true
}

rbenv::plugin { 'sstephenson/ruby-build': }
rbenv::build { '2.1.1': global => true }

class { 'postgresql::server':
  ip_mask_deny_postgres_user => '0.0.0.0/32',
  ip_mask_allow_all_users    => '0.0.0.0/0',
  listen_addresses           => '*',
  ipv4acls                   => ['hostssl all johndoe 192.168.0.0/24 cert'],
  manage_firewall            => true,
  postgres_password          => 'mypass',
}

file { "/home/vagrant/bundle" :
  ensure => directory,
  owner => "vagrant",
  group => "vagrant"
}
