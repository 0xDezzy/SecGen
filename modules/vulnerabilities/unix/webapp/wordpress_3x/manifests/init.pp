class wordpress_3x {
  $secgen_parameters = ::secgen_functions::get_parameters($::base64_inputs_file)
  $version = $secgen_parameters['version'][0]
  $blog_title = $secgen_parameters['blog_title'][0]
  $admin_email = $secgen_parameters['admin_email'][0]
  $admin_password = $secgen_parameters['admin_password'][0]
  $username = $secgen_parameters['username'][0]
  $ip_address = $secgen_parameters['IP_address'][0]
  $port = $secgen_parameters['port'][0]
  $https = str2bool($secgen_parameters['https'][0])

  class { '::mysql::server': }
  class { '::mysql::bindings': php_enable => true, }

  class { '::apache':
    default_vhost => false,
    overwrite_ports => false,
    mpm_module => 'prefork',
    default_mods => ['rewrite', 'php'],
  }

  if $https {
    apache::vhost { 'wordpress':
      docroot => '/var/www/wordpress',
      port    => '443',
      ssl     => true,
    }
  } else {
    apache::vhost { 'wordpress':
      docroot => '/var/www/wordpress',
      port    => $port,
    }
  }

  class { '::wordpress':
    install_dir => '/var/www/wordpress',
    version => $version,
  } ~>
  file { '/tmp/wordpress_conf.sh':
    owner   => 'root',
    group   => 'root',
    ensure  => present,
    mode    => '0755',
    content => template('wordpress/wordpress_conf.sh.erb'),
  }
  # ~>
  # exec { 'run wordpress config script':
  #   command => '/bin/bash /tmp/wordpress_conf.sh',
  #   require => File['/tmp/wordpress_conf.sh'],
  # }
}
