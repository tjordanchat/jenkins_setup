group { 'web':
  			  ensure => 'present',
  			  gid    => '1000',
}
user { 'mitchell':
  ensure     => present,
  uid        => '1000',
  gid        => '1000',
  shell      => '/bin/bash',
  home       => '/home/mitchell'
}
