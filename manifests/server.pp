class go_ci::server{

  $go_config = hiera_hash('go_ci')
  $version = $go_config['version']
  $build = $go_config['build']

  $go_server_deb_package = "go-server-${version}-${build}.deb"
  $go_server_deb_package_url = "http://download01.thoughtworks.com/go/${version}/ga/${go_server_deb_package}"
  $go_server_package_download_path = '/var/tmp/go_server.deb'

  Exec {
    path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin"
  }

  include dependencies::java, dependencies::apache2, dependencies::unzip

  exec { 'download_go_server_package':
    command => "wget ${go_server_deb_package_url} -O ${go_server_package_download_path}",
    unless => "ls -la ${go_server_package_download_path}",
    creates => $go_server_download_path,
    timeout => 0
  }

  exec { 'install_go_server':
    command => "dpkg -i ${$go_server_package_download_path}",
    user => 'root',
    require => [Exec['download_go_server_package'], Class['dependencies::unzip'], Class['dependencies::java']]
  }

  service { 'go-server':
    ensure => running,
    require => Exec['install_go_server']
  }
}