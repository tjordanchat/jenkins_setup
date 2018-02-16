node 'puppet.localdomain' {
    include jenkins
}

class { 'jenkins':
  executors => 0,
}
