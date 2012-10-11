class nrpe ($allowed_hosts) {

  package {
    'nrpe':
      ensure => installed;
  }

  service {
    'nrpe':
      ensure  => running,
      enable  => true,
      require => Package['nrpe'];
  }

  file {
    '/etc/nrpe.d/config.cfg':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('nrpe/config.cfg.erb'),
      require => Package['nrpe'],
      notify  => Service['nrpe'];
    '/etc/nagios/nrpe.cfg':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['nrpe'];
  }

}

class nrpe::storeconfig {

  @@nagios_service {
    "check_nrpe_${hostname}":
      check_command       => 'check_nrpe',
      service_description => 'NRPE',
      host_name           => ${hostname},
      use                 => 'ntc-service',
      tag                 => 'icinga';
  }

}

class nrpe::check_ping {

  package {
    'nagios-plugins-ping':
      ensure => installed;
  }

  file {
    '/etc/nrpe.d/command_check_ping.cfg':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => 'command[check_ping]=/usr/lib/nagios/plugins/check_ping -4 -H \$ARG1$ -w 2000,50% -c 5000,75%\ncommand[check_ping6]=/usr/lib/nagios/plugins/check_ping -6 -H \$ARG1$ -w 2000,50% -c 5000,75%\n',
      require => Package['nrpe'],
      notify  => Service['nrpe'];
  }

}

define nrpe::check_ping::storeconfig {

  include nrpe::check_ping

  @@nagios_service {
    "check_ping_${hostname}_${name}":
      check_command       => "check_ping_remote!${name}",
      service_description => "PING ${name}",
      host_name           => ${hostname},
      use                 => 'ntc-service',
      tag                 => 'icinga';
  }

}

define nrpe::check_ping6::storeconfig {

  include nrpe::check_ping

  @@nagios_service {
    "check_ping6_${hostname}_${name}":
      check_command       => "check_ping6_remote!${name}",
      service_description => "PING6 ${name}",
      host_name           => ${hostname},
      use                 => 'ntc-service',
      tag                 => 'icinga';
  }

}

class nrpe::check_file_age {

  package {
    'nagios-plugins-file_age':
      ensure => installed;
  }

  file {
    '/etc/nrpe.d/command_check_file_age.cfg':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => 'command[check_file_age]=/usr/lib/nagios/plugins/check_file_age -f \$ARG1$ -w \$ARG2$ -c \$ARG3$ -W \$ARG4$ -C \$ARG5$ \n',
      require => Package['nrpe'],
      notify  => Service['nrpe'];
  }

}

define nrpe::check_file_age::storeconfig ($warn_secs = 240,
                                          $crit_secs = 600,
                                          $warn_size = 0,
                                          $crit_size = 0) {

  include nrpe::check_file_age

  @@nagios_service {
    "check_file_age_${hostname}_${name}":
      check_command       => "check_file_age!${name}!${warn_secs}!${crit_secs}!${warn_size}!${crit_size}",
      service_description => inline_template("FILE AGE <%= File.basename(name) %>"),
      host_name           => ${hostname},
      use                 => 'ntc-service',
      tag                 => 'icinga';
  }

}

class nrpe::nagios-plugins-load {

  package {
    'nagios-plugins-load':
      ensure => installed;
  }

  file {
    '/etc/nrpe.d/command_nagios-plugins-load.cfg':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => 'command[check_load]=/usr/lib/nagios/plugins/check_load -w \$ARG1$ -c \$ARG2$ \n',
      require => Package['nrpe'],
      notify  => Service['nrpe'];
  }

}

class nrpe::nagios-plugins-users {

  package {
    'nagios-plugins-users':
      ensure => installed;
  }

  file {
    '/etc/nrpe.d/command_nagios-plugins-users.cfg':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => 'command[check_users]=/usr/lib/nagios/plugins/check_users -w \$ARG1$ -c \$ARG2$ \n',
      require => Package['nrpe'],
      notify  => Service['nrpe'];
  }

}

class nrpe::nagios-plugins-procs {

  package {
    'nagios-plugins-procs':
      ensure => installed;
  }

  file {
    '/etc/nrpe.d/command_nagios-plugins-procs.cfg':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => 'command[check_procs]=/usr/lib/nagios/plugins/check_procs -w \$ARG1$ -c \$ARG2$ \n',
      require => Package['nrpe'],
      notify  => Service['nrpe'];
  }

}

class nrpe::nagios-plugins-hpasm {

  package {
    'nagios-plugins-hpasm':
      ensure => installed;
  }

  file {
    '/etc/nrpe.d/command_nagios-plugins-hpasm.cfg':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => 'command[check_hpasm]=/usr/lib/nagios/plugins/check_hpasm \n',
      require => Package['nrpe'],
      notify  => Service['nrpe'];
  }

  sudo::spec {
    'nrpe_hpasmcli':
      users    => 'nrpe',
      hosts    => 'ALL',
      commands => '(ALL) NOPASSWD: /sbin/hpasmcli';
  }

}

class nrpe::nagios-plugins-ntc {

  package {
    'nagios-plugins-ntc':
      ensure => installed;
  }

  file {
    '/etc/nrpe.d/command_nagios-plugins-ntc.cfg':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => '\
command[check_cpu_usage]=/usr/lib/nagios/plugins/check_cpu_usage
command[check_mem_usage]=/usr/lib/nagios/plugins/check_mem_usage
command[check_java_memory]=/usr/lib/nagios/plugins/check_java_memory -p \$ARG1$
command[check_whoami]=/usr/lib/nagios/plugins/check_whoami
',
      require => Package['nrpe'],
      notify  => Service['nrpe'];
  }

  sudo::spec {
    'nrpe_jstat':
      users    => 'nrpe',
      hosts    => 'ALL',
      commands => '(ALL) NOPASSWD: /usr/bin/jstat';
  }

}

class nrpe::nagios-plugins-swap {

  package {
    'nagios-plugins-swap':
      ensure => installed;
  }

  file {
    '/etc/nrpe.d/command_nagios-plugins-swap.cfg':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => 'command[check_swap]=/usr/lib/nagios/plugins/check_swap -w \$ARG1$ -c \$ARG2$ \n',
      require => Package['nrpe'],
      notify  => Service['nrpe'];
  }

}

class nrpe::nagios-plugins-tellitec {

  package {
    'nagios-plugins-nrpe-tellitec':
      ensure => installed;
  }

  file {
    '/etc/nrpe.d/command_nagios-plugins-tellitec.cfg':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => 'command[check_tc-shape-server_shaping-ratio]=/usr/lib/nagios/plugins/check_tc-shape-server_accounting --instances \$ARG1$ --group \$ARG2$ --statistic \'Minimum Shaping Ratio\' --statistic \'Maximum Shaping Ratio\' --statistic \'Average Shaping Ratio\' \n',
      require => Package['nrpe'],
      notify  => Service['nrpe'];
  }

}
