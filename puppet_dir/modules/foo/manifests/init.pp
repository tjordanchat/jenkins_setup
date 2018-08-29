class foo {
  file {
    "/tmp/hello":
      ensure => file,
      source => "/etc/puppet/modules/foo/files/hello";
  }
}
