class install_docker {
   include ::docker
   class { 'docker' :
     manage_package => true,
        package_name   => 'docker-engine',
     }
}
node 'localhost' {
    include jenkins
}
