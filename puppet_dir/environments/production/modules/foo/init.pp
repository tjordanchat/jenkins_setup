class foo {
  file {
    "/tmp/hello":
      ensure => file,
      source => "puppet:///modules/foo/hello";
  }
}
