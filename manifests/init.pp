class nrpe ($allowed_hosts) {

  package {
    "nrpe":
      ensure => installed;
  }

  service {
    "nrpe":
      enable  => true,
      ensure  => running,
      require => Package["nrpe"];
  }

  file {
    "/etc/nrpe.d/config.cfg":
      owner   => "root",
      group   => "root",
      mode    => 0644,
      content => template("nrpe/config.cfg.erb"),
      require => Package["nrpe"],
      notify  => Service["nrpe"];
    "/etc/nagios/nrpe.cfg":
      owner   => "root",
      group   => "root",
      mode    => "0644",
      ensure  => file,
      require => Package["nrpe"];
  }

}

class nrpe::storeconfig {

  @@nagios_service { 
    "check_nrpe_${hostname}":
      check_command       => 'check_nrpe',
      service_description => 'NRPE',
      host_name           => "${hostname}",
      use                 => 'ntc-service',
      tag                 => 'icinga';
  }
    
}

class nrpe::check_ping {

  package {
    "nagios-plugins-ping":
      ensure => installed;
  }

  file {
    "/etc/nrpe.d/command_check_ping.cfg":
      owner   => "root",
      group   => "root",
      mode    => 0644,
      content => "command[check_ping]=/usr/lib/nagios/plugins/check_ping -H \$ARG1$ -w 2000,50% -c 5000,75%",
      notify  => Service["nrpe"];
  }

}

define nrpe::check_ping::storeconfig {

  include nrpe::check_ping

  @@nagios_service {
    "check_ping_${hostname}_${name}":
      check_command       => "check_ping_remote!${name}",
      service_description => "PING ${name}",
      host_name           => "${hostname}",
      use                 => 'ntc-service',
      tag                 => 'icinga';
  }

}
